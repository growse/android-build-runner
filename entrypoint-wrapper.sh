#!/bin/sh

printf '%s\n' "scan.uploadInBackground=false" "org.gradle.configureondemand=true" >/home/runner/.gradle/gradle.properties

rsync -avzr /bootstrap/android-sdk /android-sdk

yes | /android-sdk/cmdline-tools/tools/bin/sdkmanager --update
yes | /android-sdk/cmdline-tools/tools/bin/sdkmanager --licenses

# patch /dev/kvm permissions, because screw POSIX
sudo chmod 666 /dev/kvm

/usr/bin/entrypoint-dind.sh
