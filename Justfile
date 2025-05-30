app_apk := "app/build/outputs/apk/debug/app-debug.apk"
server_apk := "app/build/outputs/apk/androidTest/debug/app-debug-androidTest.apk"
app_name := "com.github.uiautomator"
server_name := "com.github.uiautomator.test"

build: 
    ./gradlew build
    ./gradlew packageDebugAndroidTest
    
install: build
    adb uninstall {{app_name}}
    adb uninstall {{server_name}}
    adb install {{app_apk}}
    adb install {{server_apk}}

fetch:
    rm -fr assets && mkdir -p assets
    cp {{app_apk}} assets/app-uiautomator.apk
    cp {{server_apk}} assets/app-uiautomator-test.apk

rm-apk:
    rm {{app_apk}}
    rm {{server_apk}}
