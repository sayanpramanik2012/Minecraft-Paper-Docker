FROM eclipse-temurin:21-jdk-jammy

# Install dependencies for version checking
RUN apt-get update && apt-get install -y curl jq && rm -rf /var/lib/apt/lists/*

WORKDIR /minecraft/server

# Download latest PaperMC
RUN PAPER_VERSION=$(curl -s https://api.papermc.io/v2/projects/paper | jq -r '.versions[-1]') && \
    PAPER_BUILD=$(curl -s https://api.papermc.io/v2/projects/paper/versions/$PAPER_VERSION/builds | jq -r '.builds[-1].build') && \
    curl -o paper.jar -s https://api.papermc.io/v2/projects/paper/versions/$PAPER_VERSION/builds/$PAPER_BUILD/downloads/paper-$PAPER_VERSION-$PAPER_BUILD.jar

RUN echo "eula=true" > eula.txt

# Create improved script to generate server.properties
RUN echo '#!/bin/bash\n\
echo "# Generated server.properties from environment variables" > server.properties\n\
\n\
# List of environment variables to exclude (Docker/Java specific)\n\
EXCLUDE_VARS="JAVA_OPTS JAVA_MEMORY_MIN JAVA_MEMORY_MAX PATH HOSTNAME PWD HOME TERM SHLVL"\n\
\n\
# Function to check if variable should be excluded\n\
should_exclude() {\n\
    local var_name="$1"\n\
    for exclude in $EXCLUDE_VARS; do\n\
        if [[ "$var_name" == "$exclude" ]]; then\n\
            return 0\n\
        fi\n\
    done\n\
    # Exclude variables that start with underscore or contain common Docker/system prefixes\n\
    if [[ "$var_name" =~ ^_ ]] || [[ "$var_name" =~ ^DOCKER ]] || [[ "$var_name" =~ ^CONTAINER ]]; then\n\
        return 0\n\
    fi\n\
    return 1\n\
}\n\
\n\
# Process environment variables\n\
env | while IFS="=" read -r key value; do\n\
    # Skip empty lines and malformed entries\n\
    [[ -z "$key" ]] && continue\n\
    \n\
    # Skip excluded variables\n\
    if should_exclude "$key"; then\n\
        echo "Skipping excluded variable: $key"\n\
        continue\n\
    fi\n\
    \n\
    # Convert to lowercase and write to properties file\n\
    property_key=$(echo "$key" | tr "[:upper:]" "[:lower:]" | tr "_" "-")\n\
    echo "Setting property: $property_key=$value"\n\
    echo "$property_key=$value" >> server.properties\n\
done\n\
\n\
echo "Generated server.properties:"\n\
cat server.properties' > /minecraft/server/generate-properties.sh && \
chmod +x /minecraft/server/generate-properties.sh

# Expose Minecraft server port (internal container port)
EXPOSE 25565

ENV JAVA_OPTS="-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true"

# Set default memory values if not provided
ENV JAVA_MEMORY_MIN="1G"
ENV JAVA_MEMORY_MAX="4G"

# Start the Minecraft server
CMD ./generate-properties.sh && java -Xms${JAVA_MEMORY_MIN} -Xmx${JAVA_MEMORY_MAX} $JAVA_OPTS -jar paper.jar nogui