# Use the official Ruby 3.0 image as the base image
FROM ruby:3.0

# Set environment variables
ENV NODE_VERSION=16.x \
    NPM_VERSION=8.19.2

# Install system dependencies, including Java
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libssl-dev \
  default-mysql-client \
  git \
  default-jdk \
  curl \
  libmagic-dev

# Install Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - \
    && apt-get install -y nodejs

# Set JAVA_HOME environment variable
ENV JAVA_HOME="/usr/lib/jvm/default-java"
ENV PATH="$JAVA_HOME/bin:$PATH"

# Install npm and bower
RUN npm install -g npm@$NPM_VERSION && npm install -g bower

# Set the working directory
WORKDIR /app

# Copy Gemfile
COPY Gemfile ./

# Install Bundler and the required gems
RUN gem install bundler
RUN bundle config set force_ruby_platform true
RUN bundle install

# Copy the rest of the application code
COPY . .

# Copy database and secret configurations
RUN cp config/database.yml.example config/database.yml && \
    cp config/secrets.yml.example config/secrets.yml

# Install front-end dependencies with Bower
RUN bower install --allow-root

# Set environment variables for the database password
ENV DATABASE_PASSWORD=expertiza

# Expose the Rails server port
EXPOSE 3000

# Run database migrations and start the Rails server
CMD ["bash", "-c", "bundle install && rails db:migrate && rails s -b '0.0.0.0'"]
