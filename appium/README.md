# Lantern Android Appium Tests

## Running integration tests using Appium, JUnit5, and Kotlin

Appium is an automated mobile application testing framework that we can use to test the Lantern Android app.

Install Node:

    $ brew install node

Install Appium and the Appium client:

    $ npm install -g appium

Note: it is recommended you install Appium Doctor in addition to Appium. It helps fix issues with Appium and Android settings easier.

    $ npm install -g appium-doctor

Start the Appium server (in another Terminal tab)

    $ appium

Attach your Android device to USB and finally run the tests:

    $ ./gradlew test
