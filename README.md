# Lantern Android

## Overview

Lantern Android is an app that uses the Android [VpnService][4] API to
intercept and reroute all device traffic to the Lantern
circumvention tool.

This project is meant to be used inside of the context of a local clone of https://github.com/getlantern/lantern-build.

## Submodules
This project uses some shared code from a submodule that needs to be initialized with

`git submodule update --init`

## Protocol Buffers
If you update the protocol buffer definitions in protos_shared, make sure to run `make protos` to
update the generated dart code.

## Building from Android Studio

#### Prerequisites
---

* [Android Studio](https://developer.android.com/studio?gclid=Cj0KCQjw2NyFBhDoARIsAMtHtZ6iZDqZH5ST7d4xlnwfdMGD8GoquRh0Q6B_KJRmUl-MRyj-OPSPrLwaAgo7EALw_wcB&gclsrc=aw.ds)
* [Git](https://git-scm.com/downloads)
* [Android NDK](#steps-to-run-the-project)
* Android SDK from 25 up to the latest.
* [Git LFS](https://git-lfs.github.com) (more information on **STEPS TO RUN THE PROJECT**)
* [Flutter V2.0.6](https://flutter.dev/docs/development/tools/sdk/releases?tab=macos) (This is due to a custom plugin that needs to be migrated)
* [sentry-cli](https://docs.sentry.io/product/cli/installation/) (This is used for uploading native debug symbols to Sentry)

In the welcome screen choose the "Open an existing Android Studio" option and
select the folder containing this README.

You'll need the liblantern-all.aar containing the Go back-end code in order for the project to compile. That file is built automatically.

<p>&nbsp;</p>

## STEPS TO RUN THE PROJECT.
---
<p>&nbsp;</p>

### Installing required components
1. Go to the **SDK MANAGER**
2. Select **Android SDK**
3. Check the SDK from android 5.0(LOLLIPOP) up to the Latest Version at the moment.
4. Go to **SDK Tools** and check the option **Show Package Details**
5. On the Android SDK Build-Tools, check from: SDK 30 up to the latest at the moment. (is optional if you wish to add more SDK alternatives such as 27.0, 28 or 29).
6. On the NDK(Side by side) check from 20.1 up to the latest at the moment.
7. Make sure that you have the latest **Android SDK Command-line Tools**
8. Finally select the following:
   - Android Emulator
   - Android SDK Platform-Tools
   - Google play APK Expansion Library
   - Google play Instant Development SDK
   - Google Play Licensing Library
   - Google Play Services
   - Intel x86 Emulator Accelerator (HAXM installer)
9. Click on Apply and accept the Terms and Conditions.
<p>&nbsp;</p>

### Downloading LFS Files
1. Once you have installed GIT LFS, go to the root of your project
2. Open your favorite terminal and type: 
   
   > ```git lfs install```

   or you can also type:
   > ```git pull```

   that do the same task as lfs install.

### Running the project
Once the required tools are installed and the lfs are downloaded, open the project on your preferred IDE.

1. On your terminal type:
   
   > flutter pub get

2. Finally this project uses flavor as args, so type this:
   - VSCode: ```flutter run --flavor prod```
   - AndroidStudio
     - Edit the run config and add on the flavor option prod


### Extra

If you like that VSCode start running the project without the need of be constantly typing the command.
- Create a folder on the root of your project named: ```.vscode```
- Inside .vscode create a file named: ```launch.json```
- Add the following inside ```launch.json```

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Debug",
            "program": "lib/main.dart",
            "request": "launch",
            "type": "dart",
            "flutterMode": "debug",
            "args": ["--no-sound-null-safety"]
        }
    ]
}
```


<p>&nbsp;</p>

## Building from Command Line

### Go Android Library

The core Lantern functionality can be packaged into a native Android library
with:

```
make android-lib
```

Note: if you're running the first time, you have to run this command first:

```
make vendor
```

### Known issues when building the project:

**Gradle could not start your build:**

```
> Could not create service of type FileAccessTimeJournal using GradleUserHomeScopeServices.createFileAccessTimeJournal().
   > Timeout waiting to lock journal cache (/Users/<username>/.gradle/caches/journal-1). It is currently in use by another Gradle instance.
```

Just simply restart your computer.

**Android Studio tries to access proxy server**
If you're running Lantern when you start Android Studio, and then turn off Lantern, Android Studio will keep trying to access resources via the proxy (which is no longer running).
To fix this, restart Android Studio.

### Lantern Mobile App

#### Debug

To create a debug build of the full lantern mobile app:

```
make android-debug
```

To install on the default device:

```
make android-debug-install
```

or

```
make android-release-install
```

#### Staging

To build mobile for staging, use the STAGING command line argument:

```
STAGING=true make android-debug android-install
```

#### Release

The Android app is distributed in two ways, as an APK for side-loaded installation and as an app bundle (aab)
for distribution on the Google Play Store. The APKs are architecture specific whereas the app bundle contains
all 4 architectures (arm and x86 in 32-bit and 64-bit variants).

To create a release build, add the following to your
`~/.gradle/gradle.properties` file:

```
KEYSTORE_PWD=$KEYSTORE_PASSWORD
KEYSTORE_FILE=keystore.release.jks
KEY_PWD=$KEY_PASSWORD
```

You can find the exact values to add to your gradle.properties under the "Android" entry in 1Password.

Note that this same key is used both for signing standalone APKs as well as signing aab app bundles for upload to
Google Play.

To build all release packages, run:

##### Building Release Packages

```
VERSION=<version here> make package-android
```

##### Tagging a Release

This creates a git tag and updates CHANGELOG.md for the currently checked out code.

```
VERSION=<version here> make tag
```

##### Deploying a Release to QA

```
VERSION=<version here> make release-qa
```

##### Testing Auto-Update with Release Builds
Sometimes you may need to make a release bulid with an old version that is eligible for auto-update. You can do that by using the VERSION_CODE environment variable

```
APP=lantern VERSION_CODE=1 VERSION=1.0.0 make android-release
```

##### APKs

For side-loading, we currently only support a 32 bit ARM APK, which you can build like this:

```sh
SECRETS_DIR=$PATH_TO_TOO_MANY_SECRETS VERSION=2.0.0-beta1 make android-release
```

You can actually omit ANDROID_ARCH since arm32 is the default:

```sh
SECRETS_DIR=$PATH_TO_TOO_MANY_SECRETS VERSION=2.0.0-beta1 make android-release
```

To build APKs for individual architectures, you can run this:

```sh
ANDROID_ARCH=arm32 SECRETS_DIR=$PATH_TO_TOO_MANY_SECRETS VERSION=2.0.0-beta1 make android-release
ANDROID_ARCH=arm64 SECRETS_DIR=$PATH_TO_TOO_MANY_SECRETS VERSION=2.0.0-beta1 make android-release
ANDROID_ARCH=x86 SECRETS_DIR=$PATH_TO_TOO_MANY_SECRETS VERSION=2.0.0-beta1 make android-release
ANDROID_ARCH=amd64 SECRETS_DIR=$PATH_TO_TOO_MANY_SECRETS VERSION=2.0.0-beta1 make android-release
```

You can build APKs containing 32 and 64 bit versions of ARM and Intel respectively like this:

```sh
ANDROID_ARCH=arm SECRETS_DIR=$PATH_TO_TOO_MANY_SECRETS VERSION=2.0.0-beta1 make android-release
ANDROID_ARCH=386 SECRETS_DIR=$PATH_TO_TOO_MANY_SECRETS VERSION=2.0.0-beta1 make android-release
```

##### App Bundle

```sh
SECRETS_DIR=$PATH_TO_TOO_MANY_SECRETS VERSION=2.0.0-beta1 make android-bundle
```

## Testing Google Play Payments
---

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

## ktlint
---
This project is formatted and linted with ktlint using the [ktlint-gradle plugin](https://github.com/JLLeitschuh/ktlint-gradle).

You can install the [ktlint Intellij plugin](https://plugins.jetbrains.com/plugin/15057-ktlint-unofficial-)
for some support for linting within Android Studio.


### Add Commit Hook
---
./gradlew addKtlintCheckGitPreCommitHook

This adds a pre commit hook that lints all staged files upon commit.


### Manually Auto-format
---
./gradlew ktlintFormat

This auto-formats all Kotlin files in the project.


### Manually Check
---
./gradlew ktlintCheck

This manually runs the linter against all Kotlin files in the project.

### VSCode debugging
Create this `.vscode/launch.json` file: 
```
{
  // Use IntelliSense to learn about possible attributes.
  // Hover to view descriptions of existing attributes.
  // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
  "version": "0.2.0",
  "configurations": [
    {
      "name": "android-lantern (prod mode)",
      "request": "launch",
      "type": "dart",
      "flutterMode": "debug",
      "args": [
        "--no-sound-null-safety",
        "--flavor",
        "prod"
      ]
    }
  ]
}
```
