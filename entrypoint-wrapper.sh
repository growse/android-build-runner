#!/usr/bin/env bash

# Copy the container's Android SDK into the persistent storage
sudo rsync -azr /bootstrap/android-sdk/ /android-sdk/
sudo chown -R runner /android-sdk
sudo chown -R runner /home/runner/.gradle

# patch /dev/kvm permissions, because screw POSIX
sudo chmod 666 /dev/kvm

# Configure the build-specific gradle properties
touch /home/runner/.gradle/gradle.properties
gradle_properties=("scan.uploadInBackground=false" "org.gradle.console=plain" "org.gradle.daemon=false" "org.gradle.configuration-cache=false" "org.gradle.parallel=true" "org.gradle.caching=true")
for gradle_property in "${gradle_properties[@]}" ; do
  grep -qxF "$gradle_property" /home/runner/.gradle/gradle.properties || echo "$gradle_property" >>/home/runner/.gradle/gradle.properties
done

# Touch the gradle caching directory to stop the gradle-build-action from pulling / pushing it up to Github.
mkdir -p /home/runner/.gradle/caches

# Configure gradle to use the on-site remote gradle cache
mkdir -p /home/runner/.gradle/init.d/ && cp /home/runner/remoteCache.init.gradle.kts /home/runner/.gradle/init.d/remoteCache.init.gradle.kts

# Put the Android AVD store onto persistent storage
rm -rf /home/runner/.android && mkdir -p /android-sdk/user_home && ln -s /android-sdk/user_home/ /home/runner/.android

/usr/bin/entrypoint.sh
