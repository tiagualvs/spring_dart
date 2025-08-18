# Specify the Dart SDK base image version using dart:<version> (ex: dart:2.12)
FROM dart:3.9.0 AS build

# Resolve app dependencies.
WORKDIR /example
RUN apt-get update && apt-get install -y libsqlite3-dev
COPY pubspec.* ./
RUN dart pub get

# Copy app source code and AOT compile it.
COPY . .
# Ensure packages are still up-to-date if anything has changed
RUN dart pub get --offline
RUN dart run build_runner build -d
RUN dart compile exe bin/example.dart -o bin/example

# Build minimal serving image from AOT-compiled `/server` and required system
# libraries and configuration files stored in `/runtime/` from the build stage.
FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /example/bin/example /example/bin/

# Start server.
EXPOSE 8080
CMD ["/example/bin/example"]
