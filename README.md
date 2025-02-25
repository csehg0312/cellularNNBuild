# Podman Project

This repository contains a `Containerfile` (similar to Dockerfile) that defines a container image. Below are the instructions to install Podman on different platforms, build the image, and start the container.

## Table of Contents

1. [Install Podman](#install-podman)
   - [Linux](#linux)
   - [macOS](#macos)
   - [Windows](#windows)
2. [Build the Image](#build-the-image)
3. [Start the Container](#start-the-container)

---

## Install Podman

### Linux

Podman is available in most Linux distributions. Here’s how to install it:

#### Ubuntu/Debian
```bash
sudo apt-get update
sudo apt-get install -y podman
```

#### Fedora
```bash
sudo dnf install -y podman
```

#### CentOS/RHEL
```bash
sudo yum install -y podman
```

#### Arch Linux
```bash
sudo pacman -S podman
```

### macOS

Podman can be installed on macOS using Homebrew:

```bash
brew install podman
```

After installation, initialize the Podman machine:

```bash
podman machine init
podman machine start
```

### Windows

Podman can be installed on Windows using Chocolatey or manually.

#### Using Chocolatey
```bash
choco install podman
```

#### Manual Installation
1. Download the latest Podman release from the [official GitHub releases page](https://github.com/containers/podman/releases).
2. Extract the archive and add the `bin` directory to your system's PATH.

After installation, initialize the Podman machine:

```bash
podman machine init
podman machine start
```

---

## Build the Image

1. Clone this repository:

   ```bash
   git clone https://github.com/csehg0312/cellularNNBuild.git
   cd cellularNNBuild
   ```

2. Build the container image using the `Containerfile`:

   ```bash
   podman build -t cellularNN .
   ```

   Replace `cellularNN` with a name for your image.

---

## Start the Container

1. Run the container from the image you just built:

   ```bash
   podman run -d --name your-container-name cellularNN
   ```

   Replace `your-container-name` with a name for your container.

2. (Optional) If your container exposes a port, you can map it to a host port:

   ```bash
   podman run -d -p 8082:8082 -p 9000:80 -p 6379:6379 --name your-container-name your-image-name
   ```

   This maps port `80` inside the container to port `9000` on your host and other ports will be the same. 
   ! Make sure that these ports are not in use the time you start the container. !

3. Check the status of your container:

   ```bash
   podman ps
   ```

4. (Optional) Access the container's shell:

   ```bash
   podman exec -it your-container-name /bin/bash
   ```

---

## Additional Resources

- [Podman Documentation](https://docs.podman.io/)
- [Podman GitHub Repository](https://github.com/containers/podman)

---