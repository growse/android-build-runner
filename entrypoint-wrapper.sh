#!/bin/sh

sudo rsync -azr /bootstrap/android-sdk/ /android-sdk/
sudo chown -R runner /android-sdk
sudo chown -R runner /home/runner/.gradle

# patch /dev/kvm permissions, because screw POSIX
sudo chmod 666 /dev/kvm

printf '%s\n' "scan.uploadInBackground=false" "org.gradle.console=plain" "org.gradle.daemon=false" "org.gradle.configuration-cache=true" "org.gradle.parallel=true" >/home/runner/.gradle/gradle.properties

rm -rf /home/runner/.android && mkdir -p /android-sdk/user_home && ln -s /android-sdk/user_home/ /home/runner/.android

/usr/bin/entrypoint.sh
