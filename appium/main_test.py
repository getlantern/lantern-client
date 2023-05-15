import os
import time
import unittest
from appium import webdriver
from appium.options.android import UiAutomator2Options
from appium.webdriver.common.appiumby import AppiumBy

class ConnectToDevice:
    @staticmethod
    def connect_to_device(deviceName, apk_file,appPackage, appActivity ):
        options = UiAutomator2Options()
        options.platformName = 'Android'
        options.deviceName = deviceName
        options.appPackage = appPackage

        if apk_file:
            options.app = os.path.abspath(apk_file)

        if appActivity:
            options.appActivity = appActivity

        driver = webdriver.Remote('http://localhost:4723/wd/hub', options = options)
        return driver


class TestMain(unittest.TestCase):
    driver = ConnectToDevice.connect_to_device("test-device", "../lantern-installer-all-debug.apk", 
        "org.getlantern.lantern", None)
    time.sleep(5)
    # element = driver.find_element(AppiumBy.ID,"org.getlantern.lantern:id/vpnSwitch")
    # element.click()

if __name__ == '__main__':
    unittest.main()