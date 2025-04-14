FROM eclipse-temurin:21-jdk-jammy

# Install necessary tools
RUN apt-get update && \
    apt-get install -y curl wget jq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /data

# Get the latest version and build number
RUN LATEST_VERSION=$(curl -s https://api.papermc.io/v2/projects/paper | jq -r '.versions[-1]') && \
    LATEST_BUILD=$(curl -s "https://api.papermc.io/v2/projects/paper/versions/${LATEST_VERSION}/builds" | jq -r '.builds[-1].build') && \
    wget -O paper.jar "https://api.papermc.io/v2/projects/paper/versions/${LATEST_VERSION}/builds/${LATEST_BUILD}/downloads/paper-${LATEST_VERSION}-${LATEST_BUILD}.jar"

# Set eula.txt
RUN echo "eula=true" > eula.txt

# Expose Minecraft server port (internal container port)
EXPOSE 25565

# Configure JVM settings and start command
ENV JAVA_OPTS="-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true"

# Add healthcheck to verify server is running
HEALTHCHECK --interval=30s --timeout=5s --start-period=60s --retries=3 \
    CMD nc -z localhost 25565 || exit 1

# Start the Minecraft server
CMD java $JAVA_OPTS -jar paper.jar nogui

