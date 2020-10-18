package org.getlantern.lantern.activity

import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.app.ActionBarDrawerToggle
import android.content.res.TypedArray
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import androidx.drawerlayout.widget.DrawerLayout
import androidx.fragment.app.Fragment
import androidx.core.view.GravityCompat
import android.widget.ListView
import android.view.MenuItem

import org.getlantern.lantern.BuildConfig
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.model.ListAdapter
import org.getlantern.lantern.model.NavItem
import org.getlantern.lantern.model.SessionManager
import org.getlantern.lantern.R

private const val TAG = "SideBarFragment"

class SidebarActivity : AppCompatActivity() {


  private lateinit var drawerLayout: DrawerLayout
  private lateinit var drawerList: ListView
  private lateinit var drawerToggle: ActionBarDrawerToggle
  private lateinit var menuIcon: ImageView

  companion object {
    val session: SessionManager = LanternApp.getSession()
  }

  // Called when the fragment instantiates its UI view
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    setContentView(R.layout.side_bar)
    
    drawerLayout = findViewById(R.id.sideBar)
    drawerList   = findViewById(R.id.drawerList)
    menuIcon = findViewById(R.id.menuIcon)
    menuIcon.setOnClickListener {
      Log.d(TAG, "Menu icon clicked")
      finish()
    }

    initSideMenu()
    if (drawerToggle != null) {
      drawerToggle.syncState()
    }
  }

  /**
     * drawerItemClicked is called whenever an item in the
     * navigation menu is clicked on
     *
     */
  private fun drawerItemClicked(item: NavItem, position: Int) {
    Log.d(TAG, "onDrawerOpened")
  }

  private fun initSideMenu() {
     Log.d(TAG, "setupSideMenu")
    val navItems: ArrayList<NavItem>? = ArrayList<NavItem>()
    val listAdapter: ListAdapter = ListAdapter(getApplicationContext(), navItems)
    val icons:TypedArray
    val ids:TypedArray
    val titles:Array<String>
    if (session.isProUser()) {
      ids   = resources.obtainTypedArray(R.array.pro_side_menu_ids)
      icons = resources.obtainTypedArray(R.array.pro_side_menu_icons)
      titles = resources.getStringArray(R.array.pro_side_menu_options);
    } else {
      ids   = resources.obtainTypedArray(R.array.free_side_menu_ids);
      icons  = resources.obtainTypedArray(R.array.free_side_menu_icons);
      titles = resources.getStringArray(R.array.free_side_menu_options)
    }

    var i = 0
    for (title in titles) {
      val id:   Int = ids.getResourceId(i, 0)
      val icon: Int = icons.getResourceId(i, 0)
      if (id == R.id.yinbi_redemption && !session.yinbiEnabled()) {
          continue
      }
      navItems?.add(NavItem(id, titles[i], icon))
      i++
    }

    drawerList.setAdapter(listAdapter)
    drawerList.setDivider(null)

    drawerToggle = object : ActionBarDrawerToggle(
      this,
      drawerLayout,
      R.string.drawer_open, R.string.drawer_close,
    ) {
        override fun onDrawerOpened(drawerView: View) {
          super.onDrawerOpened(drawerView)
          Log.d(TAG, "onDrawerOpened")
        }

        override fun onDrawerClosed(drawerView: View) {
          super.onDrawerClosed(drawerView)
          Log.d(TAG, "onDrawerClosed")
        }
    }
    drawerLayout.addDrawerListener(drawerToggle)
  }

  override fun onOptionsItemSelected(item: MenuItem): Boolean {
    if (drawerToggle.onOptionsItemSelected(item)) {
        return true
    }
    return super.onOptionsItemSelected(item)
  }

}