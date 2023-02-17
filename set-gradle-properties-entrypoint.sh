#!/bin/sh

printf '%s\n' "scan.uploadInBackground=false" "org.gradle.configureondemand=true" > /home/runner/.gradle/gradle.properties

# Patch sdkmanager to force http

find /home/runner/android-sdk -type f -name sdkmanager -exec sed -i 's/exec "\$JAVACMD" "\$@"$/exec "$JAVACMD" "$@" --no_https/' {} \;

/usr/bin/entrypoint.sh