import org.junit.jupiter.api.Test
import org.openqa.selenium.By
import kotlin.test.assertEquals
import org.junit.jupiter.api.BeforeAll

class VpnTests : AppiumSetup() {

  @Test
  fun `Toggling switch turns VPN on`() {
      driver.findElement(By.id(VPN_SWITCH))?.click()
  }
}