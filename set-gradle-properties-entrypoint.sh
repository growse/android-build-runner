#!/bin/sh

printf '%s\n' "scan.uploadInBackground=false" "org.gradle.configureondemand=true" > /home/runner/.gradle/gradle.properties

/usr/bin/entrypoint.sh