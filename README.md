# Lantern Android

## Overview

<img src="screenshots/home1.png" height="330px" width="200px">

Lantern Android is an app that uses the Android [VpnService][4] API to
intercept and reroute all device traffic to the Lantern
circumvention tool.

## Building Lantern Android

Download the most recent copy of the Lantern Android source code using `git`:

```
git clone https://github.com/getlantern/lantern-build.git
```

Then run the following to create a debug build:

```
cd $GOPATH/src/github.com/getlantern/lantern-build
make android-debug
```

To build for staging:

```
STAGING="true" make android-debug
```

### Building from Android Studio

#### Prerequisites

* [Android Studio][1]
* Git
* [Android NDK][2]

In the welcome screen choose the "Open an existing Android Studio" option and
select the `lantern-mobile` folder inside the lantern-build project you
downloaded via git.

### Building from the Command Line

#### Prerequisites

* Java 8
* [Android NDK][2]
* [Android SDK Tools][4] (if not using Android Studio)
* Go 
* [Gomobile][8]

On Mac, you can install Java 8 and the Android development tools via Homebrew:

```
brew cask install caskroom/versions/java8
brew install ant
brew install maven
brew install gradle
brew cask install android-sdk
brew cask install android-platform-tools
brew cask install android-ndk
```

Install the latest platform tools (which includes `adb`) and the SDK tools via `sdkmanager`:

```
sdkmanager "platforms;android-26" "build-tools;27.0.3" "extras;google;m2repository" "extras;android;m2repository"
```

And add the following paths:

```bash
export ANT_HOME=/usr/local/opt/ant
export MAVEN_HOME=/usr/local/opt/maven
export GRADLE_HOME=/usr/local/opt/gradle
export ANDROID_HOME=/usr/local/opt/android-sdk
export ANDROID_NDK_HOME=/usr/local/share/android-ndk
export PATH=$PATH:$ANDROID_HOME/tools
```

#### Building `tun2socks`

Lantern Android uses [tun2socks][3] to route intercepted VPN traffic through a
local SOCKS server.

```
make build-tun2socks
```

#### Installing and Running

```
make debug-install
```

Run the app on the device from the command line:

```
adb shell am start -n org.lantern.app/org.lantern.app.activity.LanternMainActivity
```

Note - if you want to test with an emulator, run `android` and then choose
Tools -> Manage AVDs.  Create an AVD (e.g. Nexus_4) and then run the emulator
from the command line like so:

```
emulator -avd Nexus_4
```

The following settings seem to work well enough performance wise:

```
Device: 3.4" WQVGA 240x432
Target: Android 5.1.1 - API Level 22
CPU/ABI: ARM (armeabi-v7a)
Keyboard: x Hardware keyboard present
Skin: Skin with dynamic hardware controls
Front Camera: None
Back Camera: None
Memory RAM: 2048
VM Heap: 128
Internal Storage: 200
SD Card: 4GiB (probably more than necessary)
Emulation Options: x Use Host GPU
```

#### Testing the app

#### Testing Locally

##### UI Tests

`ANDROID_ARCH=all make android-test`

##### Unit Tests

`cd lantern-mobile && ./gradlew testAutoTestDebugUnitTest`

#### Testing UI on GenyMotion Cloud

Genymotion Cloud allows us to spin up temporary Android Emulator instances, run our tests on those via adb, and then shut them off.

You need to have gmsaas installed and you need to be authenticated.

`pip3 install gmsaas`

You need to configure it to point to your Android SDK:

`gmsaas config set android-sdk-path $ANDROID_HOME`

Lastly you need to log in with the [credentials in 1Password](https://start.1password.com/open/i?a=HHU7O6L7H5E33C6UDFD6Q3SYH4&v=dfgpblv7fxwdwf5dkzo6ourkfy&i=zwy7gowshbfwrkhgytwp7kkwku&h=lantern.1password.com)

`gmsaas auth login accounts@getlantern.org`

Then you can run the tests on Genymotion using:

`make android-cloud-test`

#### Debugging

First, make sure to install [Pidcat][9] (a tool to filter and colorize logcat entries for a
specific application package):

```
brew install pidcat
```

Then with Lantern running:

```
pidcat org.getlantern.lantern
```

#### Testing Google Play Payments

If you're trying to test Google Play Payments with a sideloaded build, you will need to satisfy one of the following conditions, otherwise you'll get an error saying "the item you requested is not available for purchase"
when trying to purchase in-app.

A. Your login for the Google Play Store needs to be a License Tester for our account, as described [here](https://stackoverflow.com/a/55329990)
B. Alternately, you can also try to follow [these steps](https://stackoverflow.com/a/18172192) to make sure that the build is known to Google, but this didn't work for me.

```
    Make sure to upload the signed APK to developer console.

    Make sure to install the signed APK on your device not launch the app in the debugger.

    Make sure to create a test account in your developer console.

    Setup you testing account
        Make sure to sign in your device with your test account.
        In a case of closed alpha/beta testing, make sure you have added your test account to selected testers group, you can do this on the page of management your alpha/beta version.
        In a case of closed alpha/beta testing, make sure your testing account have accepted participation in testing of this application via special invite link

    Make sure to create in app billing in your developer console and finally activate the item from the console!!! (this is the one that got me after fully following google's tutorial)

    Make sure to set VersionCode and VersionName in the manifest to be the same as the version in the developer console (Alpha, Beta or Production. Drafts does not work anymore). @alexgophermix answer worked for me.
```