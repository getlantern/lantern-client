package io.lantern.org;

import io.appium.java_client.android.Activity;
import io.appium.java_client.android.AndroidDriver;
import io.appium.java_client.android.options.UiAutomator2Options;
import io.appium.java_client.remote.MobileCapabilityType;
import io.appium.java_client.remote.MobilePlatform;
import io.appium.java_client.service.local.AppiumDriverLocalService;
import io.appium.java_client.service.local.AppiumServiceBuilder;
import io.appium.java_client.service.local.flags.GeneralServerFlag;
import static org.junit.Assert.assertEquals;
import java.io.IOException;
import org.testng.annotations.Test;
import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;
import org.testng.annotations.AfterTest;
import org.testng.annotations.BeforeTest;
import io.lantern.org.flutter.appium.FlutterElement;
import io.lantern.org.flutter.appium.FlutterFinder;

// https://stackoverflow.com/questions/59075420/an-unknown-server-side-error-occurred-while-processing-the-command-could-not-pr

//Thmp Rule=: Whenevery switch context wait atleast 1 ot 2 seconds so appium driver does not crash
public class VPNTests {

    static private AppiumDriverLocalService service;
    private AndroidDriver appiumDriver;
    // this should be dynamic
    private String LANTERN_APK_PATH = "/Users/jigarfumakiya/Documents/getlantern/mobile_app/android-lantern/build/app/outputs/flutter-apk/app-prod-debug.apk";
    private String LANTERN_PACKAGE_ID = "org.getlantern.lantern";

    @BeforeTest
    private void setUp() throws IOException {
        System.out.println("!!! Starting the Appium service");
        service = new AppiumServiceBuilder()
                .withArgument(GeneralServerFlag.ALLOW_INSECURE, "chromedriver_autodownload")
                .build();
        service.start();

        System.out.println("!!! Creating Capabilities");
        UiAutomator2Options capabilities = new UiAutomator2Options();
        
        //Re-install app each time
        capabilities.setCapability("appium:noReset", false);
        capabilities.setCapability("appium:deviceName", "Nokia 8.1");
        capabilities.setCapability(MobileCapabilityType.AUTOMATION_NAME, "Flutter");

        // Logging:
        capabilities.setCapability(MobileCapabilityType.ENABLE_PERFORMANCE_LOGGING, false);
        capabilities.setCapability("appium:logLevel", "debug");

        // Timeouts:
        capabilities.setCapability("webkitResponseTimeout", 5000);
        capabilities.setCapability(MobileCapabilityType.NEW_COMMAND_TIMEOUT, 5000);

        // Change to Flutter once done testing
        capabilities.setCapability("appium:udid", "PNXID19010901034");
        capabilities.setCapability(MobileCapabilityType.PLATFORM_VERSION, "11");
        capabilities.setCapability(MobileCapabilityType.PLATFORM_NAME, MobilePlatform.ANDROID);

        capabilities.setCapability("app", LANTERN_APK_PATH);

        appiumDriver = new AndroidDriver(service.getUrl(), capabilities);
        // Wait for first frame to render
        waitForFirstFrame();

    }

    @AfterTest
    public void tearDown() {
        if (service != null) {
            service.stop();
        }
        if (appiumDriver != null) {
            appiumDriver.quit();
        }
    }

    @Test
    void checkVPN() throws InterruptedException {
        Thread.sleep(5000);
        appiumDriver.context("NATIVE_APP");
        // We need to lunch chrome only once
        // So it will stay in context we can perform http request
        startChromeBrowser();
        // Wait for atlest 10 seconds so Appium know chrome is open
        // And it will add context to it context list
        Thread.sleep(10000);

        // Make Ip request and get Ip before VPN starts
        String beforeIp = makeIpRequest();

        appiumDriver.context("NATIVE_APP");
        appiumDriver.activateApp(LANTERN_PACKAGE_ID);
        Thread.sleep(5000);

        System.out.println("!!! 7 Creating FlutterFinder object");
        FlutterFinder flutterFinder = new FlutterFinder(appiumDriver);

        // Find the VPN switch and turn it on
        appiumDriver.context("FLUTTER");
        FlutterElement vpnSwtichFinder = flutterFinder.byType("FlutterSwitch");
        vpnSwtichFinder.click();
        Thread.sleep(2000);

        // Allow system dialog permssion
        appiumDriver.context("NATIVE_APP");
        Thread.sleep(2000);
        appiumDriver.findElement(By.id("android:id/button1")).click();
        try {
            System.out.println("!!!6 Going to Sleep");
            Thread.sleep(2000);
        } catch (InterruptedException e) {
            tearDown();
        }

        // Get ip again after turing on VPN switch
        String afterIp = makeIpRequest();

        // Ip should not be same at any case
        // same it should be fail
        // We might need add some more verification logic soon
        assertEquals(beforeIp.equals(afterIp), false);
        
        // Turn of VPN
        appiumDriver.context("FLUTTER");
        
        vpnSwtichFinder.click();
        Thread.sleep(2000);

        appiumDriver.context("NATIVE_APP");
        // Uninstall app is test run successfully
        appiumDriver.removeApp(LANTERN_PACKAGE_ID);
}

    public synchronized void waitForFirstFrame() {
        appiumDriver.executeScript("flutter:waitForFirstFrame");

    }

    private void startChromeBrowser() {
        Activity activity = new Activity("com.android.chrome", "com.google.android.apps.chrome.Main");
        activity.setStopApp(false);
        appiumDriver.startActivity(activity);
        System.out.println("Chrome browser launched");
    }

    private String makeIpRequest() throws InterruptedException {
        appiumDriver.context("WEBVIEW_chrome");
        appiumDriver.get("https://api64.ipify.org");
        Thread.sleep(5000);
        WebElement ipElement = appiumDriver.findElement(By.tagName("pre"));
        // Retrieve the IP from the element
        String ip = ipElement.getText();
        System.out.println("IP Request "+ ip.toString());
        return ip;
    }

}
