#!/usr/bin/bash

set +e

# Own the whole project directory
sudo chown builder:builder -R /project

# Activate python virtual environment
cd /project
rm -r bin/*
source ~/.project_venv/bin/activate

# Install requirements and run buildozer
python3 -m pip install -r requirements.txt
buildozer android debug
BUILDOZER_STATUS=$?

# If buildozer failed then gradle might not have enough memory, try increasing it
if [ $BUILDOZER_STATUS -ne 0 ]
then
    # Set gradle/java memory to 4g and re-run gradle manually
    cd .buildozer/android/platform/build-arm64-v8a_armeabi-v7a/dists/*/
    echo org.gradle.jvmargs=-Xmx4g >> gradle.properties
    ./gradlew clean assembleDebug

    # Copy the results to the /project/bin
    cp build/outputs/apk/debug/*.apk /project/bin/
    cd /project
fi

# Deactivate python virtual environment
deactivate
