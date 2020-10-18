package org.getlantern.lantern.fragment

import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import androidx.drawerlayout.widget.DrawerLayout
import androidx.fragment.app.Fragment
import androidx.core.view.GravityCompat

import org.getlantern.lantern.activity.SidebarActivity
import org.getlantern.lantern.R

private const val TAG = "TopBarFragment"

class TopBarFragment : Fragment() {

  companion object {
    @JvmStatic
    fun newInstance(): TopBarFragment {
      return TopBarFragment()
    }
  }

  //private lateinit var binding: FragmentTopBarBinding
  private lateinit var menuIcon: ImageView

  // Called when the fragment instantiates its UI view
  override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?,
                              savedInstanceState: Bundle?): View? {
    val view = inflater.inflate(R.layout.top_bar, container, false)
    
    menuIcon = view.findViewById(R.id.menuIcon)

    return view
  }

  override fun onActivityCreated(savedInstanceState: Bundle?) {
    super.onActivityCreated(savedInstanceState)
    menuIcon.setOnClickListener {
      Log.d(TAG, "Menu icon clicked")
      val intent = Intent(getActivity(), SidebarActivity::class.java)
      getActivity()?.startActivity(intent)
    }
  }

}