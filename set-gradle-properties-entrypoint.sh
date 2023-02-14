#!/bin/sh

printf '%s\n' "org.gradle.jvmargs=-Xmx4096m -XX:MaxPermSize=512m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8 -XX:ActiveProcessorCount=$(nproc)" "org.gradle.workers.max=$(nproc)" "scan.uploadInBackground=false" "org.gradle.configureondemand=true"> /home/runner/.gradle/gradle.properties

/usr/bin/entrypoint.sh