# Lantern Android Tests
We use Appium, a mobile application testing framework, to automate interaction with the Lantern Android app. Our integration tests are run using Appium, JUnit5, and Kotlin.

## Setup

* Appium installed on your system (if not install take look at this install [instruction](https://appium.io/docs/en/2.0/quickstart/install/) )
* Kotlin set up on your system.
* An account on BrowserStack (for live testing).

### Local Testing

For local testing, you'll need to adjust the following settings in your local config file: [here](https://github.com/getlantern/android-lantern/blob/user-journey-test-ci/appium_kotlin/app/src/test/resources/local/local_config.json)

* **app**: This should be set to the path of your APK.
* **appium:deviceName**: This should be set to your mobile device.
* **platformVersion**: This should be set to your mobile device platfrom version.
* **appium:udid**: Retrieve this ID by running **adb devices** in your terminal


### Live Testing

For live testing via BrowserStack, adjust the following settings in your [live config file](https://github.com/getlantern/android-lantern/blob/user-journey-test-ci/appium_kotlin/app/src/test/resources/live/live_config.json). You can select and modify any device from this [list](https://www.browserstack.com/list-of-browsers-and-platforms/app_automate).


### Running Tests

Once you've set the configurations, you can run your tests with the following commands:

#### * For Local Testing:

```sh
cd  appium_kotlin 
RUN_ENV=local ./gradlew test
```


#### * For Live Testing:

```sh
cd  appium_kotlin 
RUN_ENV=live ./gradlew test
```

Remember to replace RUN_ENV with local or live based on your testing environment.


Dive in and happy testing!