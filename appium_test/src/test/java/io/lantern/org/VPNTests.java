package io.lantern.org;

import io.appium.java_client.android.Activity;
import static org.junit.Assert.assertEquals;
import org.testng.annotations.Test;
import org.openqa.selenium.By;
import org.openqa.selenium.WebElement;
import org.testng.annotations.AfterTest;
import org.testng.annotations.BeforeTest;
import io.lantern.org.flutter.appium.FlutterElement;
import io.lantern.org.flutter.appium.FlutterFinder;

public class VPNTests extends BaseAndroidTest {

    protected FlutterFinder flutterFinder;

    @BeforeTest
    void setup() {
        super.setupAppium();
        flutterFinder = new FlutterFinder(appiumDriver);
    }

    @Test
    void vpnShouldProxyTraffic() throws InterruptedException {
        Thread.sleep(5000);
        switchToContext(ContextType.NATIVE_APP);
        // We need to lunch chrome only once
        // So it will stay in context we can perform http request
        // Make sure to set stop app to false
        startChromeBrowser();
        // Wait for atlest 10 seconds so Appium know chrome is open
        // And it will add context to it context list
        Thread.sleep(10000);

        // Make Ip request and get Ip before VPN starts
        String beforeIp = makeIpRequest();

        switchToContext(ContextType.NATIVE_APP);
        // appiumDriver.context("NATIVE_APP");
        appiumDriver.activateApp(LANTERN_PACKAGE_ID);
        Thread.sleep(5000);

        // Find the VPN switch and turn it on
        switchToContext(ContextType.FLUTTER);
        // appiumDriver.context("FLUTTER");
        FlutterElement vpnSwtichFinder = flutterFinder.byType("FlutterSwitch");
        vpnSwtichFinder.click();
        Thread.sleep(2000);

        // Allow system dialog permssion
        switchToContext(ContextType.NATIVE_APP);
        // appiumDriver.context("NATIVE_APP");
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
        switchToContext(ContextType.FLUTTER);
        vpnSwtichFinder.click();
        Thread.sleep(2000);

    }

    @AfterTest
    void afterTest() {
        appiumDriver.context("NATIVE_APP");
        // Uninstall app is test run successfully
        appiumDriver.removeApp(LANTERN_PACKAGE_ID);

    }

    private void startChromeBrowser() {
        // Activity activity = new Activity("com.android.chrome",
        // "com.google.android.apps.chrome.Main");
        Activity activity = new Activity("com.android.chrome", "org.chromium.chrome.browser.ChromeTabbedActivity");
        activity.setStopApp(false);
        appiumDriver.startActivity(activity);
        print("Android", "Chrome browser launched");
    }

    private String makeIpRequest() throws InterruptedException {
        switchToContext(ContextType.WEBVIEW_CHROME);
        // appiumDriver.context("WEBVIEW_chrome");
        appiumDriver.get("https://api64.ipify.org");
        Thread.sleep(5000);
        WebElement ipElement = appiumDriver.findElement(By.tagName("pre"));
        // Retrieve the IP from the element
        String ip = ipElement.getText();
        print("IP Request", "Current IP " + ip.toString());
        return ip;
    }

}
