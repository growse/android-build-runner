#!/bin/sh

printf '%s\n' "scan.uploadInBackground=false" "org.gradle.configureondemand=true" >/home/runner/.gradle/gradle.properties

sudo chown -R runner /android-sdk

yes | /bootstrap/android-sdk/cmdline-tools/tools/bin/sdkmanager --sdk_root=/android-sdk --licenses
/bootstrap/android-sdk/cmdline-tools/tools/bin/sdkmanager --sdk_root=/android-sdk "cmdline-tools;latest" "emulator" "platform-tools"

# patch /dev/kvm permissions, because screw POSIX
sudo chmod 666 /dev/kvm

/usr/bin/entrypoint-dind.sh
