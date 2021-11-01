# Lantern Android - Feature: Replica Mobile

Lantern Android is an app that uses the [VpnService][https://developer.android.com/reference/android/net/VpnService] API to intercept and reroute all device traffic to the Lantern circumvention tool.

- This feature aims to integrate the Replica File Sharing project in Android
- It is forked from the Messaging feature located in [ox/messaging](https://github.com/getlantern/android-lantern/tree/ox/messaging)
- Maintainers: @soltzen
- Initial discussion: https://github.com/getlantern/lantern-internal/issues/5010
- Task Board:
  - https://github.com/orgs/getlantern/projects/9#column-16581691
  - and sporadic tasks in https://github.com/orgs/getlantern/projects/5

## Usage

### Dependencies

* [Android Studio](https://developer.android.com/studio?gclid=Cj0KCQjw2NyFBhDoARIsAMtHtZ6iZDqZH5ST7d4xlnwfdMGD8GoquRh0Q6B_KJRmUl-MRyj-OPSPrLwaAgo7EALw_wcB&gclsrc=aw.ds)
* [Git](https://git-scm.com/downloads)
* [Android NDK](#steps-to-run-the-project)
* Android SDK from 25 up to the latest.
* [Git LFS](https://git-lfs.github.com) (more information in [Usage](#usage))
* [Flutter (latest version)](https://flutter.dev/docs/development/tools/sdk/releases?tab=macos)
* [sentry-cli](https://docs.sentry.io/product/cli/installation/) (This is used for uploading native debug symbols to Sentry)
* [gomobile](https://github.com/golang/go/wiki/Mobile#tools)

In the welcome screen choose the "Open an existing Android Studio" option and select the `android` folder.

You'll need the liblantern-all.aar containing the Go back-end code in order for the project to compile. That file is built automatically.

Do this the first time your run the project:

* Install all prerequisites
* Run `git submodule update --init --recursive`
* Run `git lfs install && git pull`
* Go to the **SDK MANAGER**
* Select **Android SDK**
* Check the SDK from android 5.0(LOLLIPOP) up to the Latest Version at the moment.
* Go to **SDK Tools** and check the option **Show Package Details**
* On the Android SDK Build-Tools, check from: SDK 30 up to the latest at the moment. (is optional if you wish to add more SDK alternatives such as 27.0, 28 or 29).
* On the NDK(Side by side) check from 20.1 up to the latest at the moment.
* Make sure that you have the latest **Android SDK Command-line Tools**
* Finally select the following:
   - Android Emulator
   - Android SDK Platform-Tools
   - Google play APK Expansion Library
   - Google play Instant Development SDK
   - Google Play Licensing Library
   - Google Play Services
   - Intel x86 Emulator Accelerator (HAXM installer)
* Click on Apply and accept the Terms and Conditions.

### Running the project

* `flutter pub get`
* `flutter run --flavor prod`

Or, run it from Android Studio if you're using that.

### Building the InternalSdk (AKA Lantern Core) as a library

The core Lantern functionality is written in Go and lives in `./internalsdk`.
It is compiled from Go using [Gomobile](https://github.com/golang/mobile) to an AAR file that lives in `./android/app/libs` and is called `liblantern-ARCH.aar`.

Package the AAR with `make android-lib-debug ANDROID_ARCH=all` (use `android-lib-prod` for a production release (i.e., one that has symbols stripped, etc.))

### Testing

#### Flutter

* Run running Flutter unit tests run `make test`
* Run running Flutter integration tests with `make integration-test`. This will run all files in `integration_test` that end in `_test.dart`.
  * To run a specific integration test, run `TEST=name make integration-test` where name is the name of the integration test file without the `.dart` suffix. For example `TEST=conversation_page_test make integration-test`
  * **BE CAREFUL RUNNING WHICH DEVICE YOU CHOOSE!!!** When you run the integration tests, you'll need to select a device. If you select a device that already has Lantern installed, that Lantern will be replaced with a new build for the integration test. Consider using an emulator to avoid wiping your data
* To run independent Flutter tests, go to the root of the project and type: `flutter test test/my_folder_test.dart`
  * in case that you need the code coverage just add the following argument: `flutter test --coverage test/my_folder_test.dart`

#### Java/Kotlin

* For testing all `android/app/src/test` tests, run `./gradlew :app:test`
* For testing all `android/app/src/androidTest` tests, run `./gradlew :app:connectedAndroidTest`
* For testing a specific an `androidTest` test, easiest is to open that file in Android Studio and clicking on the green play button next to the test
* For testing the internalsdk package, run `cd ./internalsdk && go test ./...`

#### Testing with VSCode

To run the unit test you need to input the following setup.
- Create a folder on the root of your project named: `.vscode`
- Inside .vscode create a file named: `launch.json`
- Add the following inside `launch.json`
- The segment named `program` is to specificy if you wish to run all the U.T or a specific one.

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Widget Test",
            "program": "test/",
            "request": "launch",
            "type": "dart",
            "flutterMode": "debug",
            "args": [
              "--coverage"
            ]
          }
    ]
}
```

#### Unit Test Graph

If you wanna visualize the current percentage of code coverage you need to do the following steps.

1. On your `terminal` check if you have installed: `lcov` if not then install.
2. Go to on your terminal `android-lantern/coverage` and type: `genhtml coverage/lcov.info -o coverage/html` that will generate a nice html file with the code coverage of all your files.

#### Flutter Test Drive

This test is to ensure the correct functionality of the Flutter application. In case that you need to test the functionality of the Flutter application, you need to do the following steps.

1. On your `terminal` go to the root of the project and type: `flutter drive --driver test_driver/integration_driver.dart --flavor prod --target integration_test/my_file_test.dart`
2. This will start doing a simulated build of the project and run the tests.

If you modify the code and you want to test the changes, you need to do the following steps.
1. If the file has their own test, you will need to adjust the test to the new code.
2. Finally run all the integration tests to ensure that the new code is working properly with the rest of the code.

### Making debug builds

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

### Making staging builds

To build mobile for staging, use the STAGING command line argument:

```
STAGING=true make android-debug android-install
```

### Making release builds


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

### Building release packages

```
VERSION=<version here> make package-android
```

### Tagging releases

This creates a git tag and updates CHANGELOG.md for the currently checked out code.

```
VERSION=<version here> make tag
```

### Deploying a release to QA

```
VERSION=<version here> make release-qa
```

### Testing Auto-Update with release builds
Sometimes you may need to make a release bulid with an old version that is eligible for auto-update. You can do that by using the VERSION_CODE environment variable

```
APP=lantern VERSION_CODE=1 VERSION=1.0.0 make android-release
```

### APKs

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

### Making app bundles

```sh
SECRETS_DIR=$PATH_TO_TOO_MANY_SECRETS VERSION=2.0.0-beta1 make android-bundle
```

## Code Generation

This project includes various pieces of autogenerated code like protocol buffers and routes.
All of this code can be generated by running `make codegen` or just `make`. Specific pieces of
code can be generated per the below instructions.

## Protocol buffers

If you update the protocol buffer definitions in protos_shared, make sure to run `make protos` to
update the generated dart code.

Note - you might see an error like `Can't load Kernel binary: Invalid SDK hash.`. It seems that one can ignore this.

### Autorouter

Routes are defined in `lib/core/router` and need to be compiled into `lib/core/router/router.gr.dart` whenever they're changed.
You can compile routes by running `make routes`.

## Testing Google Play payments

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

## Known issues when building the project

**Gradle could not start your build:**

```
> Could not create service of type FileAccessTimeJournal using GradleUserHomeScopeServices.createFileAccessTimeJournal().
   > Timeout waiting to lock journal cache (/Users/<username>/.gradle/caches/journal-1). It is currently in use by another Gradle instance.
```

Restart your computer.

**Android Studio tries to access proxy server**
If you're running Lantern when you start Android Studio, and then turn off Lantern, Android Studio will keep trying to access resources via the proxy (which is no longer running).
To fix this, restart Android Studio.

## VSCode configurations

If you like that VSCode start running the project without the need of be constantly typing the command.
- Create a folder on the root of your project named: `.vscode`
- Inside .vscode create a file named: `launch.json`
- Add the following inside `launch.json`

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

## Debugging with VSCode

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

## Linting

This project is formatted and linted with ktlint using the [ktlint-gradle plugin](https://github.com/JLLeitschuh/ktlint-gradle).

You can install the [ktlint Intellij plugin](https://plugins.jetbrains.com/plugin/15057-ktlint-unofficial-)
for some support for linting within Android Studio.


### Add Commit Hook

```
./gradlew addKtlintCheckGitPreCommitHook
```

This adds a pre commit hook that lints all staged files upon commit.


### Manually Auto-format

```
./gradlew ktlintFormat
```

This auto-formats all Kotlin files in the project.


### Manually Check

```
./gradlew ktlintCheck
```

This manually runs the linter against all Kotlin files in the project.
