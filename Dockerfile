FROM th089/swift:5.3.3
ARG GITTOKEN
ARG GITBRANCH

# Dependency: libsqlite3
RUN apt-get update && apt-get install -y --no-install-recommends libsqlite3-dev

# The usual copying over
COPY Package.* ./

# Init git repo and "insert" .build/artifacts if existing
RUN git clone -b $GITBRANCH https://${GITTOKEN}@github.com/JASS-2021/build-cache
# Ensure an artifacts folder exists and copy potential files
RUN mkdir -p build-cache/.build && cp -avr build-cache/.build ./

# Resolve the SPM dependencies
RUN swift package resolve

# Copy the source code
COPY Sources ./Sources
COPY Tests ./Tests

# Build the application
RUN swift build --configuration release

# update artifacts
RUN rm -r build-cache/.build && cp -avr .build build-cache

# Clean-up
RUN cd build-cache && git config user.email "julian.christl@tum.de" && git config user.name "(Auto) Julian Christl" && cd ..
RUN cd build-cache && git add . && git commit -m "" --allow-empty-message --allow-empty && git push origin HEAD && cd ..
RUN rm -r ./build-cache && rm -r ./Sources && rm -r ./Tests

# Exposes ports for Docker container
EXPOSE 8080

# Start the application (Preventing rebuilds)
CMD swift run --skip-build --skip-update