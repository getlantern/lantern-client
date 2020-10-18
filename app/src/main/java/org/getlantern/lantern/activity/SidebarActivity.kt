package org.getlantern.lantern.fragment

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

class SideBarFragment : Fragment() {

  companion object {
    @JvmStatic
    fun newInstance(): SideBarFragment {
      return SideBarFragment()
    }

    val session: SessionManager = LanternApp.getSession()
  }

  private lateinit var drawerLayout: DrawerLayout
  private lateinit var drawerList: ListView
  private lateinit var drawerToggle: ActionBarDrawerToggle

  // Called when the fragment instantiates its UI view
  override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?,
                              savedInstanceState: Bundle?): View? {
    val view = inflater.inflate(R.layout.side_bar, container, false)
    
    drawerLayout = view.findViewById(R.id.sideBar)
    drawerList   = view.findViewById(R.id.drawerList)

    return view
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
    val listAdapter: ListAdapter = ListAdapter(getActivity()?.getApplicationContext(), navItems)
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
      requireActivity(),
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

  override fun onActivityCreated(savedInstanceState: Bundle?) {
    super.onActivityCreated(savedInstanceState)
    initSideMenu()
    if (drawerToggle != null) {
      drawerToggle.syncState()
    }
  }


  override fun onOptionsItemSelected(item: MenuItem): Boolean {
    if (drawerToggle.onOptionsItemSelected(item)) {
        return true
    }
    return super.onOptionsItemSelected(item)
  }

}