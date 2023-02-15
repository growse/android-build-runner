FROM ghcr.io/actions/actions-runner-controller/actions-runner:ubuntu-20.04

RUN --mount=type=cache,target=/var/cache/apt sudo apt update && sudo apt full-upgrade -y && sudo apt install -y libgl1 libc++1-11 libtcmalloc-minimal4 cpu-checker
WORKDIR /home/runner
# Pre-fetch JDK
ARG JDK_VERSION=17.0.6+10
RUN mkdir -p /opt/hostedtoolcache/Java_Temurin-Hotspot_jdk/${JDK_VERSION}/
WORKDIR /opt/hostedtoolcache/Java_Temurin-Hotspot_jdk/${JDK_VERSION}/
RUN curl -L -o jdk.tar.gz $(curl -s "https://api.adoptium.net/v3/assets/version/$(echo ${JDK_VERSION}| jq -Rr @uri)?architecture=x64&heap_size=normal&image_type=jdk&jvm_impl=hotspot&os=linux&page=0&page_size=10&project=jdk&release_type=ga&sort_method=DEFAULT&sort_order=DESC&vendor=eclipse" -H 'accept: application/json' |jq -r .[0].binaries[0].package.link)
RUN tar -zxvf jdk.tar.gz
RUN rm jdk.tar.gz

RUN mv jdk-* x64

RUN mkdir /home/runner/.m2
ADD toolchains.xml /home/runner/.m2/toolchains.xml

ENV JAVA_HOME=/opt/hostedtoolcache/Java_Temurin-Hotspot_jdk/${JDK_VERSION}/x64

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
RUN mkdir wrapper-8.0 && cd wrapper-8.0 && touch settings.gradle.kts && ../gradle-8.0/bin/gradle wrapper --gradle-version 8.0 && ./gradlew
RUN mkdir wrapper-7.6 && cd wrapper-7.6 && touch settings.gradle.kts && ../gradle-8.0/bin/gradle wrapper --gradle-version 7.6 && ./gradlew
ADD init.gradle.kts /home/runner/.gradle/init.gradle.kts

WORKDIR /

RUN sudo rm -rf /home/runner/dummy-gradle

ADD set-gradle-properties-entrypoint.sh /
RUN sudo chmod 755 /set-gradle-properties-entrypoint.sh

RUN sudo usermod -a -G 106 runner

CMD ["/set-gradle-properties-entrypoint.sh"]
