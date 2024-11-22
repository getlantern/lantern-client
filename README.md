# Lantern App [![Go Actions Status](https://github.com/getlantern/android-lantern/actions/workflows/go.yml/badge.svg)](https://github.com/getlantern/android-lantern/actions) [![Coverage Status](https://coveralls.io/repos/github/getlantern/android-lantern/badge.svg?t=C4SaZX)](https://coveralls.io/github/getlantern/android-lantern)

Lantern APP is an app that uses the [VpnService](https://developer.android.com/reference/android/net/VpnService) API to intercept and reroute all device traffic to the Lantern circumvention tool.

## Feature: Replica Mobile

See [docs/replica.md](docs/replica.md).

## Acknowledgements

This application uses ringtone sounds from Mike Koenig available [here](https://soundbible.com/1868-Ringing-Phone.html)
and licensed under the [Creative Commons Attribution License](https://creativecommons.org/licenses/by/3.0/).

## Code Generation
This project includes various pieces of autogenerated code like protocol buffers and routes.
All of this code can be generated by running `make codegen` or just `make`. Specific pieces of
code can be generated per the below instructions.

### Protocol Buffers
If you update the protocol buffer definitions in protos_shared, make sure to run `make protos` to
update the generated dart code.

Note - you might see an error like `Can't load Kernel binary: Invalid SDK hash.`. It seems that one can ignore this.

## Building and Releasing

### Dependencies

All these dependencies must be in your PATH. Some of this is Android specific, see below for other platforms.

* Java 11 or greater
* [Android Studio](https://developer.android.com/studio?_gl=1*1wowe6v*_up*MQ..&gclid=Cj0KCQjw6auyBhDzARIsALIo6v-bn0juONfkfmQAJtwssRCQWADJMgGfRBisMNTSXHt5CZnyZVSK2Y8aAgCmEALw_wcB&gclsrc=aw.ds) (Android Studio Jellyfish | 2023.3.1 Patch 1)
* [Xcode](https://developer.apple.com/xcode/resources/)
* [Git](https://git-scm.com/downloads)
* [Android NDK](#steps-to-run-the-project)
  * NDK should be version 26.x, for example 26.0.10792818.
* [Git LFS](https://git-lfs.github.com)
  - more information in [Usage](#usage)
* [Flutter (3.24.0)](https://flutter.dev)
* [sentry-cli](https://docs.sentry.io/product/cli/installation/)
  - This is used for uploading native debug symbols to Sentry
* [gomobile](https://github.com/golang/go/wiki/Mobile#tools)
* [json-server](https://github.com/typicode/json-server)
  * Only necessary for testing Replica
* CMake 3.22.1
  * You can get this from Android SDK Manager
* [CocoaPods](https://cocoapods.org/)
  * Possibly this is only needed on Apple platforms.
* Linux
  * [libayatana-appindicator](https://github.com/AyatanaIndicators/libayatana-appindicator) (required by [tray_manager](https://github.com/leanflutter/tray_manager#linux-requirements))
  * [gstreamer](https://gstreamer.freedesktop.org/documentation/installing/on-linux.html) (required by [flutter plugin audioplayers](https://pub.dev/packages/audioplayers_linux))
  * [libclang-dev](https://apt.llvm.org) (required by [ffigen](https://pub.dev/packages/ffigen))

### 🚀 Setup Project:

* Install all prerequisites
* Run `git submodule update --init --recursive`
* Run `git lfs install && git pull`.
* Put the [app.env](https://my.1password.com/app#/everything/AllItems/whdjlkyj7ku6pumtyc7nh5vg4yadqasjh2hspgjgvgfllyekhcrq) file (Frontend vault) from 1Password in the repo root.
* Go to the **SDK MANAGER**
* Select **Android SDK**
* Check the SDK from android 5.0(LOLLIPOP) up to the Latest Version at the moment.
* Go to **SDK Tools** and check the option **Show Package Details**
* On the Android SDK Build-Tools, check from: SDK 30 up to the latest at the moment. (is optional if you wish to add more SDK alternatives such as 27.0, 28 or 29).
* On the NDK(Side by side) check the latest version of 22.x (not anything newer)
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
* Open Xcode first time open Xcode and install necessary components
* Download Certificate and provisioning profile from 1Pass [Search [IOS Certificates and profiles](https://my.1password.com/vaults/all/allitems)]
* Lastly `Flutter Doctor` to confirm that your setup is correct and ready!

### 🤖 Running the project on Android

* `make android-lib ANDROID_ARCH` (you need to generated liblantern-all.aar containing the Go backend code in order for the project to compile.)
* `flutter pub get`
* `flutter run --flavor prod`

### 🍏 Running the project on iOS

* `make build-framework` (you need to generated Internalsdk.xcframework. containing the Go backend code in order for the project to compile.)
* `flutter pub get`
* `flutter run --flavor prod`

**Note**: If you're using an M1 or M2 chip, navigate to the ios folder and run `arch -x86_64 pod install`

### 💻 Running the Project on Desktop

**Note**: Make sure to run all the commands from the root of the project.

#### macOS

* `make macos`
* `make ffigen`
* `flutter run -d macos`

#### Other OS

* Windows run `make windows` Linux run `linux-amd64`
* `make ffigen`
* `flutter pub get`
* `flutter run --flavor prod` or if you are using android studio use desktop configuration

### Running on emulators

You can easily run emulators directly from the command line with the following:

* `flutter devices`
* `flutter run -d ID --flavor prod`

### 👩‍💻 Using Android Studio? No problem!

We've got you covered! If you prefer using Android Studio, we have already set up the configuration files for you. Just select the prod configuration and hit Run... Get ready to start digging! 😄🔍

You can build an emulator with `./scripts/run_avd.rb`. Here's an example run: `./scripts/run_avd.rb --level=30 --abi=x86 --use_google_apis --window`.
You'll need Ruby >= 2.3 installed and `colorize` gem (i.e., `gem install colorize`).

[//]: # (#### Flutter Logging)

[//]: # ()
[//]: # (The Flutter component uses [logger]&#40;https://pub.dev/packages/logger&#41; package for logging.)

[//]: # (See `home.dart#build&#40;&#41;` to know where it's configured.)

[//]: # ()
[//]: # (During development, you'll notice a lot of `GoLog`-tagged code. Feel-free to comment that out during your flutter work.)

[//]: # (A sane terminal command &#40;using [pidcat]&#40;https://github.com/JakeWharton/pidcat&#41;&#41; is `pidcat org.getlantern.lantern -i GoLog -i System.out -w 3`.)

### Building the InternalSdk (AKA Lantern Core) as a library

The core Lantern functionality is written in Go and lives in `./internalsdk`.
It is compiled from Go using [Gomobile](https://github.com/golang/mobile) to appropriate formats for each platform.

#### Android
* To generate AAR run `make android-lib ANDROID_ARCH=all`

* For compiled code lives in `./android/app/libs` and is called `liblantern-ARCH.aar`.

#### IOS
* To generate XCodeFramework run `make build-framework`

For compiled code lives in `./ios/internalsdk/` and is called `Internalsdk.xcframework`.

#### Desktop
The desktop app lives under `desktop` .. To build the Go shared library on macOS:

* To build for desktop `make darwin` for macOS, `make windows` for Windows, and `make linux-amd64` for Linux.
* Generate the FFI bindings `make ffigen`

[//]: # (#### Testing against Lantern's staging servers)

[//]: # ()
[//]: # (Package the AAR with `make android-lib ANDROID_ARCH=all STAGING=true`)

### Making Android debug builds (Not yet implemented on IOS)

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

[//]: # (### 🚧 Making Staging Builds)

[//]: # ()
[//]: # ()
[//]: # (To build mobile for staging, use the STAGING command line argument:)

[//]: # ()
[//]: # (```)

[//]: # (STAGING=true make android-debug android-install)

[//]: # (```)

[//]: # ()
[//]: # (This will build Flashlight with the same [STAGING flag]&#40;https://github.com/getlantern/flashlight/v7/blob/9eb8abbe036e86b9e72a1a938f29e59f75391676/common/const.go#L43&#41;, which allows your client to use the [staging pro-server]&#40;https://github.com/getlantern/pro-server-neu/blob/fa2859edf213998e15cd7c00461e52fd97a9e570/README.md#L125&#41; instance instead of the production one.)

### 🎉 Making Release Builds

#### IOS

Do this to make a release build:
```
 VERSION=x.x.x make ios-release
```
**Note**: Replace x.x.x with the version number of your release.

This will
- Set the version number in the info.plist file and increment the build number 1
- Upload the DSYM file to Sentry
- Open the build folder once the build is complete


#### Android
The Android app is distributed in two ways, as an APK for side-loaded installation and as an app bundle (aab) for distribution on the Google Play Store. The APKs are architecture specific whereas the app bundle contains all 4 architectures (arm and x86 in 32-bit and 64-bit variants).

Do this to make a release build:

- Make sure `./android/local.properties` exists. If not, create it to look like this (Replace with your own values. Find `flutter.sdk` by running `flutter doctor -v`):

        ```
        sdk.dir=/Users/AwesomeLanternDev/Library/Android/sdk
        flutter.sdk=/opt/homebrew/Caskroom/flutter/3.3.4/flutter
        ```

- Download [sentry-cli](https://docs.sentry.io/product/cli/installation/)
  - Authenticate with [these credentials](https://my.1password.com/vaults/all/allitems/npsu55phkvbytbomlhnfuhqcii) by running `sentry-cli login`. You need this, else the Makefile task will fail
- Download [this release keystore](https://my.1password.com/vaults/all/allitems/rp5dzcli5ghilzfsanajwz6nqm) file and put it somewhere like `/tmp/mykeystore,jks`
- Replace `~/.gradle/gradle.properties` with the values found [here](https://my.1password.com/vaults/all/allitems/jq67eb556b44gb6nlfjm2yh3tq)
  - Make sure to replace `KEYSTORE_FILE` with the location of your keystore (`/tmp/mykeystore,jks` in our case above)
- Run `VERSION=<version here> make android-release ANDROID_ARCH=all`
  - Or, `DEVELOPMENT_MODE=true make android-release ANDROID_ARCH=all` to enable "Development Mode" which has extra dev features like taking screenshots and dev settings.

### 📦 Building Release Packages and Distributing the App

Lantern-client release and beta packages are built using Continuous Integration (CI). You can create installers for beta, production, or internal testing by adjusting the tag syntax. 

#### Production Release for All Platforms 🌍

To release the production version for all platforms (including Android, iOS, and macOS), use the following command:

`git tag -a "lantern-7.0.0" -f -m "Tagging production release"`

To build a beta, simply include "beta" in the tag, as in:

`git tag -a "lantern-7.0.0-beta" -f -m "Tagging beta release"`

Finally, to create an internal build, use "internal", as in:

`git tag -a "lantern-7.0.0-internal" -f -m "Tagging internal release"`


#### Platform-Specific Releases 📱💻

For releasing to specific platforms, use the appropriate prefix:

* iOS: ios-
* Android: android-
* Desktop (Windows, macOS, Linux): desktop-

Example command for releasing a beta version for Android:

`git tag -a "android-lantern-7.0.0" -f -m "Tagging production release"`

This command will build and release the beta version for Android.

#### Pushing Tags to GitHub 🛠️

After creating a tag, push it to GitHub to trigger the CI/CD pipeline:

`git push origin [TAG-NAME]`or `git push origin lantern-7.0.0`

You can then find all built binaries in the [lantern-binaries repository](https://github.com/getlantern/lantern-binaries).

To publish a release on Google Play, go to the Lantern App on the [Google Play Console](https://play.google.com/console/u/0/developers/4642290275832863621/app/4973965144252805146/app-dashboard?timespan=thirtyDays) and create a new release using the [app bundle](lantern-installer.aab).

### Enabling Auto-Update for a Sideloaded Release

Just because something's been released to prod doesn't mean clients will auto-update, there's an additional step for that. The below will release the current production version to autoupdate. Please make sure the VERSION parameter matches the current production version.

```
GH_TOKEN=<token> VERSION=7.2.0 make auto-updates
```

To find the latest version that's been set for auto updates, check the [lantern](https://github.com/getlantern/lantern/releases) repo.

You can obtain the GH_TOKEN for releasing auto-updates from [1Password](https://start.1password.com/open/i?a=HHU7O6L7H5E33C6UDFD6Q3SYH4&v=nupvcrpazomdrozlmemsywqfj4&i=qlxf7ffkjnhu7nqkshvwi7ocpm&h=lantern.1password.com).

### Testing Auto-Update with release builds
Sometimes you may need to make a release build with an old version that is eligible for auto-update. You can do that by using the VERSION_CODE environment variable

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

## 🧪 Testing
For testing we are using [patrol](https://pub.dev/packages/patrol) framework, Patrol simplifies interaction with the native layer and offers an extensive set of easy-to-use testing APIs.

### Integration Testing

#### Writing Integration Testing
* Always use our custom [patrol](https://github.com/getlantern/lantern-client/blob/d5c36eba30e8072c0327eca4eea8472cbfa49cb5/integration_test/utils/test_utils.dart#L54) method for writing any new integration tests. Similarly, utilize [appTearDown](https://github.com/getlantern/lantern-client/blob/d5c36eba30e8072c0327eca4eea8472cbfa49cb5/integration_test/utils/test_utils.dart#L95) for cleanup. These methods ensure compatibility across different environments for mobile and desktop platforms.
* Structure tests to simulate real user flows, such as changing app settings (e.g., language preferences) or completing actions
* Ensure tests are compatible with all supported platforms (mobile and desktop).
* If mocks are necessary for specific scenarios, ensure they are clearly documented and cover all critical edge cases.


#### Running Integration Testing

* Make sure you install patrol_cli globally by running `flutter pub global activate patrol_cli`
* Make sure to connect any device or emulator to run the test.

To run all integration the test on mobile
```sh
make appWorkflowTest
```

To run and single test on mobile
```sh
make runTest testfile or make runTest integration_test/app_startup_flow_test.dart
```

To run all integration the test on desktop
```sh
make desktopWorkflowTest
```

To run and single test on dekstop
```sh
make runDesktopTest testfile or integration_test/app_startup_flow_test.dart
```

#### Running Test on Firebase Test Lab

##### Setup
* Install `gcloud CLI`. If not, you can install it by following the instructions [here](https://cloud.google.com/sdk/docs/install).
* Login to your Google Cloud account by running `gcloud auth login`.
* Set the project ID by running `gcloud config set project lantern-android`.


#### Running the test
To Run test on android device on Firebase Test Lab, you need to run the following command:
```sh
make ci-android-test
```

#### Testing Replica
A few Replica tests run [json-server](https://github.com/typicode/json-server) to serve dummy data during tests instead of hitting an actual Replica instance.
The tests should transparently setup and teardown the dummy server but you need to have `json-server` in your PATH.

### Java/Kotlin

* For testing all `android/app/src/test` tests, run `./gradlew :app:test`
* For testing all `android/app/src/androidTest` tests, run `./gradlew :app:connectedAndroidTest`
* For testing a specific an `androidTest` test, easiest is to open that file in Android Studio and clicking on the green play button next to the test
* For testing the internalsdk package, run `cd ./internalsdk && go test ./...`

### Unit Test Graph

If you wanna visualize the current percentage of code coverage you need to do the following steps.

1. On your `terminal` check if you have installed: `lcov` if not then install.
2. Go to on your terminal `android-lantern/coverage` and type: `genhtml coverage/lcov.info -o coverage/html` that will generate a nice html file with the code coverage of all your files.

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

## Testing Freekassa Payments

You'd most probably wanna run this against Lantern's staging servers **and** turn on testing mode for Freekassa. Unfortunately in Freekassa, once you turn on `Testing Mode`, you can't switch back without affecting live payments. Ideally, contant Freekassa support to see how you can enable a separate testing mode. I'll just mention here some helpful notes while testing Freekassa before we went live with it.

- Building the Flashlight library (i.e., `internalsdk`) with `make android-lib ANDROID_ARCH=all STAGING=true` is tempting, but it's not gonna work since all staging proxies you'll use (i.e., `fallback-*` proxies did not work at all for me as of today <25-12-2022, soltzen>).
  - You'll need to do the incredibly-hacky approach of modifying this function `LanternHttpClient:createProUrl`:

        public static HttpUrl createProUrl(final String uri, final Map<String, String> params) {
            // final String url = String.format("http://localhost/pro%s", uri);
            final String url = String.format("https://api-staging.getiantem.org%s", uri);
            HttpUrl.Builder builder = HttpUrl.parse(url).newBuilder();
            if (params != null) {
                for (Map.Entry<String, String> param : params.entrySet()) {
                    builder.addQueryParameter(param.getKey(), param.getValue());
                }
            }
            return builder.build();
        }

- You can debug pro-server-neu's staging instance (i.e., `api-staging.getiantem.org`) using a combination of log, telemetry and checking the staging Redis instance (see [here](https://github.com/getlantern/pro-server-neu/blob/c79c1b8da9e418bc4b075392fde9b051c699141d/README.md?plain=1#L125) for more info)

## Running Appium tests locally

To run the Appium tests locally with a connected device, you need to follow a few steps:

1. Install appium with npm:

```bash
npm install -g appium
```

2. Install the necessary drivers:

```bash
appium driver install uiautomator2
appium driver install --source=npm appium-flutter-driver
appium driver install espresso
```

3. Generate a debug build with `CI=true make android-debug ANDROID_ARCH=all` ... CI needs to be set to true to enable the
   Flutter driver extension.

4. Modify [local_config.json](appium_kotlin/app/src/test/resources/local/local_config.json) to specify the path of a debug build APK on your system, and change `appium:udid` to specify your device ID (you can get this from `adb devices`)

5. Make sure your device is connected to your computer and then run

```bash
cd appium_kotlin
./gradlew test
```

To run a specific test, you can do

```bash
./gradlew test --tests '*GooglePlay*'
```

## Source Dump
Lantern Android source code is made available via source dump tarballs. To create one, run:

```
VERSION=2.0.0 make sourcedump
```

This will create a file `lantern-android-sources-2.0.0.tar.gz`.

This tarball deliberately excludes UI resources like images and localized strings. It also deliberately excludes 3rd party Java libraries from the libs folder.

The tarball does include vendored Go libraries, including all of the getlantern.org Go libraries. In this tarball, these are all licensed under the GPL
as explained in [LICENSING.md](LICENSING.md).

All embedded URL literals in the getlantern.org Go code are elided to make it harder for clones to build a working version of Lantern.

TODO: once we're confident these are working well, we should automate the upload of these to S3 and GitHub along with the upload of releases.

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
      "args": [
        "--no-sound-null-safety",
        "--flavor",
        "prod",
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

## FAQ

### Why is there a long-running notification?

We run Lantern as a foreground service so that it remains on and connected with our messaging server. Typical Android applications use Google Play Services for push notifications, so they don't have have to maintain this kind of connection themselves.

We can't use Google Play Services because:

- A lot of our users don't even have Google Play Services installed
- Google is blocked in a lot of placess
- Some people view using Google for delivering messages as a privacy issue
