#!/bin/sh

printf '%s\n' "scan.uploadInBackground=false" "org.gradle.configureondemand=true" >/home/runner/.gradle/gradle.properties

sudo rsync -avzr /bootstrap/android-sdk /android-sdk

sudo chown -R runner /android-sdk

# patch /dev/kvm permissions, because screw POSIX
sudo chmod 666 /dev/kvm

mkdir /android-sdk/user_home && ln -s /android-sdk/user_home /home/runner/.android

/home/runner/run.sh
