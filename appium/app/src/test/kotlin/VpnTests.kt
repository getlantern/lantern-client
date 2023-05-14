import org.junit.jupiter.api.Test
import org.openqa.selenium.By
import kotlin.test.assertEquals

class VpnTests : AppiumSetup() {

    protected val find: FlutterFinder

  @Before
  @Throws(::Exception)
  fun setUp() {
    super.setUp()
    find = FlutterFinder(driver)
  }


    @Test
    fun `Simple multiplication give correct result`() {
        driver.findElement(By.id(VPN_SWITCH)).click()
    }
}