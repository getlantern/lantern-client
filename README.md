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

See https://github.com/getlantern/lantern-build for instructions on how to build from the command line

## Building from Android Studio

#### Prerequisites

* [Android Studio][1]
* Git
* [Android NDK][2]

In the welcome screen choose the "Open an existing Android Studio" option and
select the folder containing this README.

You'll need the liblantern-all.aar containing the Go back-end code in order for the project to compile. That file is built automatically.

## Testing Google Play Payments

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
This project is formatted and linted with ktlint using the [ktlint-gradle plugin](https://github.com/JLLeitschuh/ktlint-gradle).

You can install the [ktlint Intellij plugin](https://plugins.jetbrains.com/plugin/15057-ktlint-unofficial-)
for some support for linting within Android Studio.

### Add Commit Hook
./gradlew addKtlintCheckGitPreCommitHook

This adds a pre commit hook that lints all staged files upon commit.

### Manually Auto-format
./gradlew ktlintFormat

This auto-formats all Kotlin files in the project.

### Manually Check
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