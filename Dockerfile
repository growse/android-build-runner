FROM ghcr.io/actions/actions-runner-controller/actions-runner:ubuntu-20.04

RUN --mount=type=cache,target=/var/cache/apt sudo apt update && sudo apt full-upgrade -y && sudo apt install -y openjdk-17-jdk-headless libgl1 libc++1-11 libtcmalloc-minimal4
RUN mkdir -p /home/runner/android-sdk/cmdline-tools
WORKDIR /home/runner/android-sdk/cmdline-tools
RUN curl -L -o commandlinetools-linux.zip https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip && unzip commandlinetools-linux.zip && mv cmdline-tools tools && rm commandlinetools-linux.zip

RUN yes | /home/runner/android-sdk/cmdline-tools/tools/bin/sdkmanager --licenses
RUN yes | /home/runner/android-sdk/cmdline-tools/tools/bin/sdkmanager --update

RUN /home/runner/android-sdk/cmdline-tools/tools/bin/sdkmanager --install "cmdline-tools;latest"
RUN /home/runner/android-sdk/cmdline-tools/tools/bin/sdkmanager --install "platform-tools"
RUN /home/runner/android-sdk/cmdline-tools/tools/bin/sdkmanager --install "build-tools;33.0.2"
RUN /home/runner/android-sdk/cmdline-tools/tools/bin/sdkmanager --install "build-tools;30.0.3"
RUN /home/runner/android-sdk/cmdline-tools/tools/bin/sdkmanager --install "platforms;android-33"
RUN /home/runner/android-sdk/cmdline-tools/tools/bin/sdkmanager --install "system-images;android-31;google_apis;x86_64"
ENV ANDROID_SDK_ROOT=/home/runner/android-sdk

WORKDIR /home/runner
RUN mkdir /home/runner/.gradle

RUN mkdir /home/runner/dummy-gradle/
WORKDIR /home/runner/dummy-gradle
RUN touch settings.gradle.kts && curl -L -o gradle.zip https://services.gradle.org/distributions/gradle-8.0-bin.zip && unzip gradle.zip && ./gradle-8.0/bin/gradle tasks
ADD init.gradle.kts /home/runner/.gradle/init.gradle.kts

WORKDIR /

RUN sudo rm -rf /home/runner/dummy-gradle

ADD set-gradle-properties-entrypoint.sh /
RUN sudo chmod 755 /set-gradle-properties-entrypoint.sh

CMD ["/set-gradle-properties-entrypoint.sh"]
