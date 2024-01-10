# syntax=docker/dockerfile:1

FROM gradle:8.5.0 as wrapper-8.5.0
RUN mkdir /wrapper
WORKDIR /wrapper
ENV GRADLE_USER_HOME=/wrapper/.gradle
RUN touch settings.gradle.kts && gradle wrapper --gradle-version 8.5 --distribution-type bin --gradle-distribution-sha256-sum=9d926787066a081739e8200858338b4a69e837c3a821a33aca9db09dd4a41026 && ./gradlew tasks

# Build the runner based on actions-runner-dind
FROM ghcr.io/actions-runner-controller/actions-runner-controller/actions-runner:v2.311.0-ubuntu-22.04

RUN --mount=type=cache,target=/var/cache/apt sudo apt update && sudo apt full-upgrade -y && sudo apt install -y libgl1 libc++1-11 libtcmalloc-minimal4 cpu-checker htop rsync curl unzip git libvulkan1 tzdata

ENV JAVA_HOME=/opt/java/openjdk

COPY --from=eclipse-temurin:17.0.9_9-jdk-jammy $JAVA_HOME $JAVA_HOME
ENV PATH="${JAVA_HOME}/bin:${PATH}"

RUN sudo chown -R runner /home/runner/

RUN sudo mkdir -p /bootstrap/android-sdk/cmdline-tools
RUN sudo chown -R runner /bootstrap
WORKDIR /bootstrap/android-sdk/cmdline-tools
RUN curl -L -o commandlinetools-linux.zip https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip && unzip commandlinetools-linux.zip && mv cmdline-tools tools && rm commandlinetools-linux.zip

RUN yes | /bootstrap/android-sdk/cmdline-tools/tools/bin/sdkmanager --sdk_root=/bootstrap/android-sdk --licenses
RUN /bootstrap/android-sdk/cmdline-tools/tools/bin/sdkmanager --sdk_root=/bootstrap/android-sdk "cmdline-tools;latest" "emulator" "platform-tools" "platforms;android-34" "build-tools;34.0.0"

ENV ANDROID_SDK_ROOT=/android-sdk
ENV ANDROID_HOME=/android-sdk
ENV ANDROID_USER_HOME=/android-sdk/user_home
ENV ANDROID_AVD_HOME=/android-sdk/user_home/avd

WORKDIR /home/runner
RUN mkdir /home/runner/.gradle

ADD init.gradle.kts /home/runner/.gradle/init.gradle.kts

WORKDIR /

RUN sudo mkdir /android-sdk
ADD entrypoint-wrapper.sh /

RUN sudo chmod 755 /entrypoint-wrapper.sh

COPY --from=wrapper-8.5.0 /wrapper/.gradle/ /home/runner/.gradle/

RUN sudo chown -R runner:runner /home/runner/.gradle

WORKDIR /

CMD ["/entrypoint-wrapper.sh"]
