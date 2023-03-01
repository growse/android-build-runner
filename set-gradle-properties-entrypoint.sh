#!/bin/sh

printf '%s\n' "scan.uploadInBackground=false" "org.gradle.configureondemand=true" >/home/runner/.gradle/gradle.properties

# Patch sdkmanager to force http so that it uses the proxy
find /home/runner/android-sdk -type f -name sdkmanager -exec sed -i 's/exec "\$JAVACMD" "\$@"$/exec "$JAVACMD" "$@" --no_https/' {} \;

# patch /dev/kvm permissions, because screw POSIX
sudo chmod 666 /dev/kvm

/usr/bin/entrypoint.sh
