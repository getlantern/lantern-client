package org.getlantern.lantern.fragment

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.fragment.app.Fragment
import org.getlantern.lantern.databinding.TitleFragmentBinding

class TopBarFragment:Fragment()
{

  private lateinit var binding: TopBarBinding

  override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?,
                              savedInstanceState: Bundle?): View? {
    binding = DataBindingUtil.inflate(
      inflater, R.layout.top_bar, container, false)
    return binding.root
  }
}