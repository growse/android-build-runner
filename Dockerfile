FROM node:19.7-alpine3.17 as javaSetup
RUN apk --update add git
RUN mkdir -p /home/runner
WORKDIR /home/runner
RUN git clone --branch v3.10.0 --depth=1 https://github.com/actions/setup-java.git

WORKDIR /home/runner/setup-java/dist/setup
RUN env "INPUT_DISTRIBUTION=temurin" "INPUT_JAVA-VERSION=17" "INPUT_JAVA-PACKAGE=jdk" "RUNNER_TEMP=/runner/_work/_temp/" "RUNNER_TOOL_CACHE=/opt/hostedtoolcache" node index

FROM ghcr.io/actions/actions-runner-controller/actions-runner-dind:ubuntu-22.04

RUN --mount=type=cache,target=/var/cache/apt sudo apt update && sudo apt full-upgrade -y && sudo apt install -y libgl1 libc++1-11 libtcmalloc-minimal4 cpu-checker htop

COPY --from=javaSetup /opt/hostedtoolcache /opt/hostedtoolcache
COPY --from=javaSetup /root/.m2/toolchains.xml /home/runner/.m2/toolchains.xml
RUN sudo chown -R runner /home/runner/

RUN sudo mkdir -p /bootstrap/android-sdk/cmdline-tools
RUN sudo chown -R runner /bootstrap
WORKDIR /bootstrap/android-sdk/cmdline-tools
RUN curl -L -o commandlinetools-linux.zip https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip && unzip commandlinetools-linux.zip && mv cmdline-tools tools && rm commandlinetools-linux.zip

RUN sudo ln -s $(dirname $(find /opt/hostedtoolcache/ -name release)) /opt/jdk
ENV JAVA_HOME=/opt/jdk

RUN yes | /bootstrap/android-sdk/cmdline-tools/tools/bin/sdkmanager --licenses

# RUN /home/runner/android-sdk/cmdline-tools/tools/bin/sdkmanager --install "cmdline-tools;latest"
# RUN /home/runner/android-sdk/cmdline-tools/tools/bin/sdkmanager --install "platform-tools"

ENV ANDROID_SDK_ROOT=/android-sdk

WORKDIR /home/runner
RUN mkdir /home/runner/.gradle

RUN mkdir /home/runner/dummy-gradle/
WORKDIR /home/runner/dummy-gradle
RUN touch settings.gradle.kts && curl -L -o gradle.zip https://services.gradle.org/distributions/gradle-8.0.2-bin.zip && unzip gradle.zip && ./gradle-8.0.2/bin/gradle tasks
RUN mkdir wrapper-8.0.2 && cd wrapper-8.0.2 && touch settings.gradle.kts && ../gradle-8.0.2/bin/gradle wrapper --gradle-version 8.0.2 && ./gradlew
RUN mkdir wrapper-7.6.1 && cd wrapper-7.6.1 && touch settings.gradle.kts && ../gradle-8.0.2/bin/gradle wrapper --gradle-version 7.6.1 && ./gradlew
ADD init.gradle.kts /home/runner/.gradle/init.gradle.kts

WORKDIR /

RUN sudo rm -rf /home/runner/dummy-gradle

ADD entrypoint-wrapper.sh /

RUN sudo chmod 755 /entrypoint-wrapper.sh

CMD ["/entrypoint-wrapper.sh"]
