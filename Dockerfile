FROM th089/swift:5.3.3

# Dependency: libsqlite3
RUN apt-get update && apt-get install -y --no-install-recommends libsqlite3-dev

# The usual copying over
COPY Package.* ./
COPY Sources ./Sources
COPY Tests ./Tests

RUN ls -al
# Resolve the SPM dependencies
RUN swift package resolve
RUN ls -al
RUN ls -al .build

# Build the application
RUN swift build --configuration release
RUN ls -al
RUN ls -al .build

# Exposes ports for Docker container
EXPOSE 8080

# Start the application (Preventing rebuilds)
CMD swift run --skip-build --skip-update