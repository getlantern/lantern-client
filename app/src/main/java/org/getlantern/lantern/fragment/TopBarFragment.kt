package org.getlantern.lantern.fragment

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
//import androidx.databinding.DataBindingUtil
import androidx.fragment.app.Fragment

import org.getlantern.lantern.R
//import org.getlantern.lantern.databinding.FragmentTopBarBinding


class TopBarFragment:Fragment()
{

  //private lateinit var binding: FragmentTopBarBinding

  override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?,
                              savedInstanceState: Bundle?): View? {
    return inflater.inflate(R.layout.top_bar, container, false)
    /*binding = DataBindingUtil.inflate(
      inflater, R.layout.top_bar, container, false)
    return binding.root*/
  }
}