# Minecraft Paper Server Docker

## Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Quick Start with Docker Compose](#quick-start-with-docker-compose)
- [Configuration](#configuration)
  - [Memory Settings](#memory-settings)
  - [Server Properties](#server-properties)
- [Directory Structure](#directory-structure)
- [How It Works](#how-it-works)
- [Updating](#updating)
- [Backup and Restore](#backup-and-restore)
  - [Backup](#backup)
  - [Restore](#restore)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgments](#acknowledgments)

A Dockerized Minecraft Paper server setup that automatically fetches the latest version and provides easy configuration through environment variables.

## Features

- 🚀 **Automatic Updates**: Automatically fetches the latest PaperMC version
- 🛠️ **Easy Configuration**: Configure server settings through environment variables
- 💾 **Persistent Storage**: Worlds and plugins are stored in a local directory
- 🔒 **Secure**: Runs as a non-root user inside the container
- 🚀 **Optimized**: Uses Aikar's flags for optimal Java performance
- 🔄 **Auto-restart**: Container automatically restarts unless explicitly stopped

## Prerequisites

- Docker
- Docker Compose
- At least 10GB of RAM recommended for the host system

## Quick Start

1. Clone this repository:

```bash
git clone https://github.com/sayanpramanik2012/Minecraft-Paper-Docker
cd minecraft-paper-docker
```

2. Create the necessary directories:

```bash
mkdir -p minecraft-docker-paper/{world,world_nether,world_the_end,plugins}
```

3. Start the server:

```bash
docker compose up -d
```

## Quick Start with Docker Compose

The easiest way to run this Minecraft Paper server is using Docker Compose. Simply:

1. Copy the `docker-compose.yml` file from this repository
2. Run `docker-compose up -d` to start the server
3. The server will automatically download the latest stable version of Paper

The server will be accessible on port 25565 by default. You can modify the port and other settings in the `docker-compose.yml` file.

## Configuration

### Memory Settings

The server is configured to use 4GB minimum and 10GB maximum RAM by default. You can modify these values in `docker-compose.yml`:

```yaml
environment:
  - JAVA_MEMORY_MIN=4G
  - JAVA_MEMORY_MAX=10G
```

### Server Properties

All server properties can be configured through environment variables in `docker-compose.yml`. The current configuration includes:

- Port: 2515 (external) / 25565 (internal)
- Difficulty: Hard
- Max Players: 1000
- View Distance: 30
- And many more settings...

## Directory Structure

```
minecraft-docker-paper/
├── world/           # Overworld data
├── world_nether/    # Nether data
├── world_the_end/   # End data
└── plugins/         # Plugin files
```

## How It Works

1. **Dockerfile**:

   - Uses Eclipse Temurin Java 21 as the base image
   - Automatically fetches the latest PaperMC version
   - Sets up a secure, non-root user environment
   - Configures optimal JVM settings

2. **docker-compose.yml**:
   - Manages container configuration
   - Handles volume mounts for persistence
   - Sets environment variables for server configuration
   - Configures networking and ports

## Updating

To update to the latest PaperMC version:

```bash
docker compose build --no-cache
docker compose up -d
```

## Backup and Restore

### Backup

Simply copy the `minecraft-docker-paper` directory:

```bash
cp -r minecraft-docker-paper minecraft-docker-paper-backup
```

### Restore

Replace the directory with your backup:

```bash
rm -rf minecraft-docker-paper
cp -r minecraft-docker-paper-backup minecraft-docker-paper
docker compose restart
```

## Contributing

Feel free to submit issues and enhancement requests!

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [PaperMC](https://papermc.io/) for the server software
- [Aikar's Flags](https://mcflags.emc.gs) for JVM optimization
- [Eclipse Temurin](https://adoptium.net/) for the Java runtime
