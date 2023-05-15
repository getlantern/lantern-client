# Lantern Android Appium Tests

## Running integration tests using Appium, JUnit5, and Kotlin

Appium is a mobile application testing framework that we use to automate interaction with the Lantern Android app.

## Setup

Install Node:

    $ brew install node

Install Appium and the Appium client:

    $ npm install -g appium

Note: it is recommended you install Appium Doctor in addition to Appium. It makes it easier to fix issues with Appium and Android settings.

    $ npm install -g appium-doctor

Start the Appium server (in another Terminal tab)

    $ appium

Attach your Android device to USB and finally run the tests:

    $ ./gradlew test
