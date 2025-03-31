# Use the Debian Lite image
FROM python:3.11-slim

# Set environment variables
ENV APP_HOME /app
ENV POETRY_VERSION=1.8.3  
ENV JULIA_VERSION=1.11.2   
# ENV BUN_VERSION=1.1.26
ENV HOST=0.0.0.0

ENV JULIA_PYTHON_HOST=0.0.0.0
ENV JULIA_PYTHON_PORT1=50001
ENV JULIA_PYTHON_PORT2=50002
ENV JULIA_PYTHON_PORT3=50003
ENV REDIS_PORT=6379
ENV REDIS_HOST=0.0.0.0
ENV PORT1=8080
ENV PORT2=8081
ENV PORT3=8082

ENV CLIENT_WS_PORT_START=40001
ENV CLIENT_WS_PORT_END=40010

# Install necessary packages
RUN apt-get update && \
    apt-get install -y \
        nano \
        python3.11 \
        python3.11-venv \
        python3-pip \
        curl \
        gnupg2 \
        lsb-release \
        software-properties-common \
        redis-server \
        git \
        unzip \
        nginx \
        supervisor \
        libgl1-mesa-glx \
        libglib2.0-0 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    git clone https://github.com/csehg0312/cellularNN && \
    cd cellularNN

# Create application directory
RUN mkdir -p $APP_HOME

# Set the working directory
WORKDIR $APP_HOME


# Install Poetry
RUN curl -sSL https://install.python-poetry.org | python3.11 - && \
    ln -s /root/.local/bin/poetry /usr/local/bin/poetry

# Install Julia
RUN curl -fsSL https://install.julialang.org | sh -s -- -y && \
    ln -s /root/.juliaup/bin/julia /usr/local/bin/julia && \
    ln -s /root/.juliaup/bin/juliaup /usr/local/bin/juliaup && \
    julia --version

# Install Bun
RUN curl -sSL https://bun.sh/install | bash -s "bun-v1.1.26" && \
    ln -s /root/.bun/bin/bun /usr/local/bin/bun
    
# Copy the contents of the cloned repository to the application directory
RUN mv -r /cellularNN/* $APP_HOME/ && rm -rf /cellularNN

# Install Python dependencies using Poetry
RUN poetry install --no-root

RUN poetry run python julia_install.py

WORKDIR $APP_HOME/frontend
RUN bun install
RUN bun run vite build

WORKDIR $APP_HOME

WORKDIR $APP_HOME/utils
RUN poetry run python pkl_save.py
RUN mv settings.pkl ..
WORKDIR $APP_HOME

# Add these before copying configurations
RUN mkdir -p /var/log/nginx /var/log/supervisor && \
    touch /var/run/nginx.pid && \
    chmod -R 755 /var/log/nginx /var/log/supervisor

# Add proper permissions for Nginx
RUN chown -R www-data:www-data /var/log/nginx && \
    chmod -R 755 /etc/nginx

# Copy supervisord configuration
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Copy Nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

RUN printenv | sed 's/^/export /' > /app/.env

# Expose ports for Nginx and your application
EXPOSE 80 6379 8080 8081 8082

# Command to run Redis server in the background and then your application
# CMD ["sh", "-c", "redis-server --daemonize yes && poetry run python app.py"]
CMD ["supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
