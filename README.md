# Lantern Android

## Overview

Lantern Android is an app that uses the Android [VpnService][4] API to
intercept and reroute all device traffic to the Lantern
circumvention tool.

This project is meant to be used inside of the context of a local clone of https://github.com/getlantern/lantern-build.

## Submodules
This project uses some shared code from a submodule that needs to be initialized with

`git submodule update --init`

## Building from Command Line
---

See https://github.com/getlantern/lantern-build for instructions on how to build from the command line

\n
## Building from Android Studio

#### Prerequisites
---

* [Android Studio](https://developer.android.com/studio?gclid=Cj0KCQjw2NyFBhDoARIsAMtHtZ6iZDqZH5ST7d4xlnwfdMGD8GoquRh0Q6B_KJRmUl-MRyj-OPSPrLwaAgo7EALw_wcB&gclsrc=aw.ds)
* [Git](https://git-scm.com/downloads)
* [Android NDK](#steps-to-run-the-project)
* Android SDK from 25 up to the latest.
* [Git LFS](https://git-lfs.github.com) (more information on **STEPS TO RUN THE PROJECT**)
* [Flutter V2.0.6](https://flutter.dev/docs/development/tools/sdk/releases?tab=macos) (This is due to a custom plugin that needs to be migrated)

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
5. On the Android SDK Build-Tools, check from: SDK 27.0.0 up to the latest at the moment.
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
