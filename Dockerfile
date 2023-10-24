# syntax=docker/dockerfile:1

# Fetch the JDK
FROM node:21.0-alpine3.17 as javaSetup
RUN apk --update add curl
RUN mkdir -p /home/runner
WORKDIR /home/runner
# renovate: datasource=github-releases depName=actions/setup-java
ENV SETUP_JAVA_VERSION=v3.13.0
RUN curl -L -O https://github.com/actions/setup-java/archive/refs/tags/${SETUP_JAVA_VERSION}.tar.gz && tar -zxvf ${SETUP_JAVA_VERSION}.tar.gz
RUN mv setup-java-* setup-java

WORKDIR /home/runner/setup-java/dist/setup
# Fix bug in index.js when running on GHA
RUN sed -e '/add-matcher/ s|^.|//|' -i index.js 
RUN env "INPUT_DISTRIBUTION=temurin" "INPUT_JAVA-VERSION=17" "INPUT_JAVA-PACKAGE=jdk" "RUNNER_TEMP=/runner/_work/_temp/" "RUNNER_TOOL_CACHE=/opt/hostedtoolcache" node index

FROM gradle:8.4.0 as wrapper-8.2.1
RUN mkdir /wrapper
WORKDIR /wrapper
ENV GRADLE_USER_HOME=/wrapper/.gradle
RUN touch settings.gradle.kts && gradle wrapper --gradle-version 8.2.1 --distribution-type bin --gradle-distribution-sha256-sum=03ec176d388f2aa99defcadc3ac6adf8dd2bce5145a129659537c0874dea5ad1 && ./gradlew tasks

# Build the runner based on actions-runner-dind
FROM ghcr.io/actions-runner-controller/actions-runner-controller/actions-runner-dind:v2.311.0-ubuntu-22.04

RUN --mount=type=cache,target=/var/cache/apt sudo apt update && sudo apt full-upgrade -y && sudo apt install -y libgl1 libc++1-11 libtcmalloc-minimal4 cpu-checker htop rsync

COPY --from=javaSetup /opt/hostedtoolcache /opt/hostedtoolcache
COPY --from=javaSetup /root/.m2/toolchains.xml /home/runner/.m2/toolchains.xml
RUN sudo chown -R runner /home/runner/

RUN sudo mkdir -p /bootstrap/android-sdk/cmdline-tools
RUN sudo chown -R runner /bootstrap
WORKDIR /bootstrap/android-sdk/cmdline-tools
RUN curl -L -o commandlinetools-linux.zip https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip && unzip commandlinetools-linux.zip && mv cmdline-tools tools && rm commandlinetools-linux.zip

RUN sudo ln -s $(dirname $(find /opt/hostedtoolcache/ -name release)) /opt/jdk
ENV JAVA_HOME=/opt/jdk

ENV ANDROID_SDK_ROOT=/android-sdk
ENV ANDROID_HOME=/android-sdk
ENV ANDROID_USER_HOME=/android-sdk/user_home
ENV ANDROID_AVD_HOME=/android-sdk/user_home/avd

WORKDIR /home/runner
RUN mkdir /home/runner/.gradle

ADD init.gradle.kts /home/runner/.gradle/init.gradle.kts

WORKDIR /

RUN sudo rm -rf /home/runner/dummy-gradle

RUN sudo mkdir /android-sdk
ADD entrypoint-wrapper.sh /

RUN sudo chmod 755 /entrypoint-wrapper.sh

COPY --from=wrapper-8.2.1 /wrapper/.gradle/ /home/runner/.gradle/

RUN sudo chown -R runner:runner /home/runner/.gradle

WORKDIR /

CMD ["/entrypoint-wrapper.sh"]
