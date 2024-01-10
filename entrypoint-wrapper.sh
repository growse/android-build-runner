#!/usr/bin/env bash

sudo rsync -azr /bootstrap/android-sdk/ /android-sdk/
sudo chown -R runner /android-sdk
sudo chown -R runner /home/runner/.gradle

# patch /dev/kvm permissions, because screw POSIX
sudo chmod 666 /dev/kvm

touch /home/runner/.gradle/gradle.properties
gradle_properties=("scan.uploadInBackground=false" "org.gradle.console=plain" "org.gradle.daemon=false" "org.gradle.configuration-cache=false" "org.gradle.parallel=true" "org.gradle.caching=true")
for gradle_property in "${gradle_properties[@]}" ; do
  grep -qxF "$gradle_property" /home/runner/.gradle/gradle.properties || echo "$gradle_property" >>/home/runner/.gradle/gradle.properties
done

mkdir -p /home/runner/.gradle/init.d/ && ln -s /home/runner/remoteCache.init.gradle.kts /home/runner/.gradle/init.d/remoteCache.init.gradle.kts

rm -rf /home/runner/.android && mkdir -p /android-sdk/user_home && ln -s /android-sdk/user_home/ /home/runner/.android

/usr/bin/entrypoint.sh
