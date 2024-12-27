# Dockerfile
FROM python:3.11-slim AS base

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV FLASK_SECRET_KEY='M!technicalmod-test2024'

# Install git
RUN apt-get update && \
    apt-get install -y git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
    
# Set the working directory
WORKDIR /app

# Copy the requirements file and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . .

# Ensure the .git directory is copied
COPY .git .git

# Expose the port the app runs on
EXPOSE 3000

# Build stage for testing
FROM base AS test

# Run unit tests
RUN python -m unittest discover -s tests

# Final stage
FROM base AS final

# Run the application
CMD ["python", "app.py"]