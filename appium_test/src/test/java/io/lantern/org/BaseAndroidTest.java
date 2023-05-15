package io.lantern.org;

import org.testng.annotations.AfterSuite;
import org.testng.annotations.BeforeSuite;

import io.appium.java_client.android.AndroidDriver;
import io.appium.java_client.android.options.UiAutomator2Options;
import io.appium.java_client.remote.MobileCapabilityType;
import io.appium.java_client.remote.MobilePlatform;
import io.appium.java_client.service.local.AppiumDriverLocalService;
import io.appium.java_client.service.local.AppiumServerHasNotBeenStartedLocallyException;
import io.appium.java_client.service.local.AppiumServiceBuilder;
import io.appium.java_client.service.local.flags.GeneralServerFlag;

public class BaseAndroidTest {

    // Enums representing the context types
    public enum ContextType {
        NATIVE_APP,
        FLUTTER,
        WEBVIEW_CHROME
    }

    static private AppiumDriverLocalService service;
    public AndroidDriver appiumDriver;
    // this should be dynamic
    private String LANTERN_APK_PATH = "/Users/jigarfumakiya/Documents/getlantern/mobile_app/android-lantern/build/app/outputs/flutter-apk/app-prod-debug.apk";
    public String LANTERN_PACKAGE_ID = "org.getlantern.lantern";

    @BeforeSuite
    void setupAppium() {
        print("Base Android Test", "Starting the Appium service");
        service = new AppiumServiceBuilder()
                .withArgument(GeneralServerFlag.ALLOW_INSECURE, "chromedriver_autodownload")
                .build();

        service.start();
        if (service == null || !service.isRunning()) {
            throw new AppiumServerHasNotBeenStartedLocallyException("An appium server node is not started!");
        }

        print("Base Android Test", "Creating Capabilities");

        UiAutomator2Options capabilities = new UiAutomator2Options();

        // Re-install app each time
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
        capabilities.setCapability("setWebContentsDebuggingEnabled", "true");

        capabilities.setCapability("app", LANTERN_APK_PATH);

        appiumDriver = new AndroidDriver(service.getUrl(), capabilities);
        // Wait for first frame to render
        waitForFirstFrame();
    }

    @AfterSuite
    void tearDown() {
        if (service != null) {
            service.stop();
            print("Android", "Appium service stopped");
        }
        if (appiumDriver != null) {
            appiumDriver.quit();
            print("Android", "Appium driver quit");

        }
    }

    public synchronized void waitForFirstFrame() {
        appiumDriver.executeScript("flutter:waitForFirstFrame");
    }

    protected void switchToContext(ContextType contextType) {
        print("Android", "Available to context: " + appiumDriver.getContextHandles());
        String context = getContextString(contextType);
        appiumDriver.context(context);
        print("Android", "Switched to context: " + context);

    }

    private String getContextString(ContextType contextType) {
        switch (contextType) {
            case NATIVE_APP:
                return "NATIVE_APP";
            case FLUTTER:
                return "FLUTTER";
            case WEBVIEW_CHROME:
                return "WEBVIEW_chrome";
            default:
                throw new IllegalArgumentException("Invalid context type: " + contextType);
        }
    }

    protected void print(String tag, String message) {
        System.out.println("[" + tag + "] " + message);
    }
}
