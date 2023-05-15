import os
import time
import unittest
from appium import webdriver
from appium.webdriver.common.appiumby import AppiumBy

appium_server_url = 'http://localhost:4723/wd/hub'

class ConnectToDevice:
    @staticmethod
    def connect_to_device(deviceName, apk_file,appPackage, appActivity ):
        capabilities = {}
        capabilities['platformName'] = 'Android'
        capabilities['deviceName'] = deviceName


        if apk_file:
            capabilities['app'] = os.path.abspath(apk_file)
        capabilities["appPackage"] = appPackage
        if appActivity:
            capabilities['appActivity'] = appActivity

        driver = webdriver.Remote(appium_server_url, capabilities)
        return driver


class TestMain(unittest.TestCase):
    driver = ConnectToDevice.connect_to_device("test-device", "../lantern-installer-all-debug.apk", 
        "org.getlantern.lantern", None)
    time.sleep(5)
    # element = driver.find_element(AppiumBy.ID,"org.getlantern.lantern:id/vpnSwitch")
    # element.click()

if __name__ == '__main__':
    unittest.main()