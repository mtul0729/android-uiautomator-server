FROM docker.io/openjdk:17-bullseye AS android-builder

RUN apt update && apt install -y \
    git \
    unzip \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Android SDK
ENV ANDROID_SDK_ROOT /opt/android-sdk
ENV ANDROID_HOME /opt/android-sdk
ENV PATH ${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools

RUN mkdir -p ${ANDROID_SDK_ROOT} && \
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O /tmp/sdk.zip && \
    unzip -q /tmp/sdk.zip -d /tmp/cmdline-tools && \
    mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    mv /tmp/cmdline-tools/cmdline-tools ${ANDROID_SDK_ROOT}/cmdline-tools/latest && \
    rm -rf /tmp/sdk.zip /tmp/cmdline-tools && \
    yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" "platforms;android-34" "platforms;android-30" "build-tools;30.0.3"


FROM android-builder

# Create workspace directory
WORKDIR /app

# Copy project files
COPY . .

RUN chmod +x gradlew && ./gradlew --quiet androidGitVersion

# Build APKs
RUN ./gradlew build
RUN ./gradlew packageDebugAndroidTest

# Create dist directory and copy APKs
RUN mkdir -p /output/dist && \
    cp app/build/outputs/apk/debug/app-debug.apk /output/dist/app-uiautomator.apk && \
    cp app/build/outputs/apk/androidTest/debug/app-debug-androidTest.apk /output/dist/app-uiautomator-test.apk

# Set volume for output
VOLUME /output

# Default command to show the APK paths
CMD ["ls", "-la", "/output/dist"]
