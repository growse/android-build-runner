#!/usr/bin/env bash

sudo rsync -azr /bootstrap/android-sdk/ /android-sdk/
sudo chown -R runner /android-sdk
sudo chown -R runner /home/runner/.gradle

# patch /dev/kvm permissions, because screw POSIX
sudo chmod 666 /dev/kvm

touch /home/runner/.gradle/gradle.properties
gradle_properties=("scan.uploadInBackground=false" "org.gradle.console=plain" "org.gradle.daemon=false" "org.gradle.configuration-cache=true" "org.gradle.parallel=true")
for gradle_property in "${gradle_properties[@]}" ; do
  grep -qxF "$gradle_property" /home/runner/.gradle/gradle.properties || echo "$gradle_property" >>/home/runner/.gradle/gradle.properties
done

rm -rf /home/runner/.android && mkdir -p /android-sdk/user_home && ln -s /android-sdk/user_home/ /home/runner/.android

/usr/bin/entrypoint.sh
