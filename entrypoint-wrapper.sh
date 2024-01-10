#!/bin/sh

printf '%s\n' "scan.uploadInBackground=false" "org.gradle.console=plain" "org.gradle.workers.max=1" "org.gradle.daemon=false" "org.gradle.configuration-cache=true" "org.gradle.parallel=true" >/home/runner/.gradle/gradle.properties

sudo rsync -azr /bootstrap/android-sdk/ /android-sdk/

sudo chown -R runner /android-sdk

# patch /dev/kvm permissions, because screw POSIX
sudo chmod 666 /dev/kvm

rm -rf /home/runner/.android && mkdir -p /android-sdk/user_home && ln -s /android-sdk/user_home/ /home/runner/.android

/usr/bin/entrypoint.sh
