#!/bin/sh

printf '%s\n' "scan.uploadInBackground=false" "org.gradle.configureondemand=true" >/home/runner/.gradle/gradle.properties

yes | /bootstrap/android-sdk/cmdline-tools/tools/bin/sdkmanager --update

# patch /dev/kvm permissions, because screw POSIX
sudo chmod 666 /dev/kvm

/usr/bin/entrypoint-dind.sh
