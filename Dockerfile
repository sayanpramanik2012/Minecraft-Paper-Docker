FROM eclipse-temurin:21-jdk-jammy

# Install dependencies for version checking
RUN apt-get update && apt-get install -y curl jq && rm -rf /var/lib/apt/lists/*

WORKDIR /minecraft/server

# Download latest PaperMC
RUN PAPER_VERSION=$(curl -s https://api.papermc.io/v2/projects/paper | jq -r '.versions[-1]') && \
    PAPER_BUILD=$(curl -s https://api.papermc.io/v2/projects/paper/versions/$PAPER_VERSION/builds | jq -r '.builds[-1].build') && \
    curl -o paper.jar -s https://api.papermc.io/v2/projects/paper/versions/$PAPER_VERSION/builds/$PAPER_BUILD/downloads/paper-$PAPER_VERSION-$PAPER_BUILD.jar

RUN echo "eula=true" > eula.txt

# Create startup script that handles server.properties properly
RUN echo '#!/bin/bash\n\
set -e\n\
\n\
# Function to update server.properties\n\
update_server_properties() {\n\
    echo "Updating server.properties with environment variables..."\n\
    \n\
    # List of environment variables to exclude\n\
    EXCLUDE_VARS="JAVA_OPTS JAVA_MEMORY_MIN JAVA_MEMORY_MAX PATH HOSTNAME PWD HOME TERM SHLVL"\n\
    \n\
    # Create a temporary properties file\n\
    temp_props="/tmp/server.properties.tmp"\n\
    \n\
    # If server.properties exists, use it as base, otherwise create empty\n\
    if [ -f "server.properties" ]; then\n\
        cp server.properties "$temp_props"\n\
    else\n\
        touch "$temp_props"\n\
    fi\n\
    \n\
    # Process environment variables\n\
    env | while IFS="=" read -r key value; do\n\
        # Skip empty lines and malformed entries\n\
        [[ -z "$key" ]] && continue\n\
        \n\
        # Skip excluded variables\n\
        skip=false\n\
        for exclude in $EXCLUDE_VARS; do\n\
            if [[ "$key" == "$exclude" ]]; then\n\
                skip=true\n\
                break\n\
            fi\n\
        done\n\
        \n\
        # Skip Docker/system variables\n\
        if [[ "$key" =~ ^_ ]] || [[ "$key" =~ ^DOCKER ]] || [[ "$key" =~ ^CONTAINER ]]; then\n\
            skip=true\n\
        fi\n\
        \n\
        if [ "$skip" = true ]; then\n\
            continue\n\
        fi\n\
        \n\
        # Convert to lowercase with hyphens\n\
        property_key=$(echo "$key" | tr "[:upper:]" "[:lower:]" | tr "_" "-")\n\
        \n\
        # Update or add the property\n\
        if grep -q "^${property_key}=" "$temp_props"; then\n\
            # Property exists, update it\n\
            sed -i "s/^${property_key}=.*/${property_key}=${value}/" "$temp_props"\n\
            echo "Updated: ${property_key}=${value}"\n\
        else\n\
            # Property does not exist, add it\n\
            echo "${property_key}=${value}" >> "$temp_props"\n\
            echo "Added: ${property_key}=${value}"\n\
        fi\n\
    done\n\
    \n\
    # Replace the original file\n\
    mv "$temp_props" "server.properties"\n\
    echo "server.properties updated successfully"\n\
}\n\
\n\
# First, start the server briefly to generate default files\n\
echo "Generating default server files..."\n\
timeout 30s java -Xms512M -Xmx512M -jar paper.jar nogui || true\n\
\n\
# Now update the server.properties with our environment variables\n\
update_server_properties\n\
\n\
echo "Starting Minecraft server with updated configuration..."\n\
echo "Final server.properties:"\n\
cat server.properties\n\
echo "=========================================="\n\
\n\
# Start the server with proper memory settings\n\
exec java -Xms${JAVA_MEMORY_MIN} -Xmx${JAVA_MEMORY_MAX} $JAVA_OPTS -jar paper.jar nogui' > /minecraft/server/start-server.sh && \
chmod +x /minecraft/server/start-server.sh

# Expose Minecraft server port (internal container port)
EXPOSE 25565

ENV JAVA_OPTS="-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true"

# Set default memory values if not provided
ENV JAVA_MEMORY_MIN="1G"
ENV JAVA_MEMORY_MAX="4G"

# Use the new startup script
CMD ["./start-server.sh"]