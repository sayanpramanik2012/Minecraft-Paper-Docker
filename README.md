# Minecraft Paper Server Docker

## Table of Contents

- [Features](#features)
- [Versioning](#versioning)
- [Automated Builds](#automated-builds)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Quick Start with Docker Compose](#quick-start-with-docker-compose)
- [Configuration](#configuration)
  - [Memory Settings](#memory-settings)
  - [Server Properties](#server-properties)
  - [Environment Variables](#environment-variables)
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
- ⚙️ **Dynamic Properties**: Server properties are automatically generated from environment variables

## Versioning

The Docker images follow a specific versioning scheme:
- Format: `{paper-version}-v{build-number}`
- Example: `1.20.4-v1`, `1.20.4-v2`, etc.
- The `latest` tag always points to the most recent build
- Images are automatically built for both `linux/amd64` and `linux/arm64` platforms

## Automated Builds

This project uses GitHub Actions to automatically:
- Build and push Docker images on every push to main branch
- Support manual triggers for specific Paper versions
- Automatically detect and use the latest stable Paper version
- Increment build numbers for each new build of the same Paper version
- Push images to Docker Hub with proper versioning

## Prerequisites

- Docker
- Docker Compose
- At least 1GB of RAM recommended for the host system

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
  - JAVA_MEMORY_MIN=1G
  - JAVA_MEMORY_MAX=1G
```

### Server Properties

All server properties can be configured through environment variables in `docker-compose.yml`. The environment variables are automatically converted to the appropriate format in `server.properties`. Here's how it works:

1. Environment variables in `docker-compose.yml` are automatically converted to lowercase
2. They are then written to `server.properties` when the container starts
3. Any changes to environment variables require a container restart to take effect

Example configuration in `docker-compose.yml`:
```yaml
environment:
  - DIFFICULTY=hard
  - MAX_PLAYERS=1000
  - VIEW_DISTANCE=30
  - MOTD=Welcome to my server!
```

### Environment Variables

Here are some commonly used environment variables you can configure:

| Variable | Description | Default |
|----------|-------------|---------|
| `DIFFICULTY` | Game difficulty | hard |
| `MAX_PLAYERS` | Maximum number of players | 1000 |
| `VIEW_DISTANCE` | View distance in chunks | 30 |
| `MOTD` | Message of the day | Welcome to server! |
| `WHITE_LIST` | Enable whitelist | true |
| `ONLINE_MODE` | Enable online mode | true |
| `SPAWN_PROTECTION` | Spawn protection radius | 1 |
| `GAMEMODE` | Default game mode | survival |
| `PVP` | Enable PvP | true |
| `LEVEL_NAME` | World name | world |
| `LEVEL_TYPE` | World type | minecraft:normal |
| `ENABLE_COMMAND_BLOCK` | Enable command blocks | true |
| `SIMULATION_DISTANCE` | Simulation distance | 20 |
| `SPAWN_MONSTERS` | Spawn monsters | true |
| `SPAWN_ANIMALS` | Spawn animals | true |
| `SPAWN_NPCS` | Spawn NPCs | true |

For a complete list of available properties, refer to the [Minecraft Wiki](https://minecraft.fandom.com/wiki/Server.properties).

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
   - Generates server.properties from environment variables

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
