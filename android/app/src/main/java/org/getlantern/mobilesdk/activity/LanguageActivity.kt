package org.getlantern.mobilesdk.activity

import android.content.Intent
import android.graphics.Rect
import android.os.Bundle
import android.view.View
import android.widget.ListView
import androidx.fragment.app.FragmentActivity
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.R
import org.getlantern.lantern.activity.Launcher
import org.getlantern.lantern.databinding.LanguagesBinding
import org.getlantern.mobilesdk.Logger
import org.getlantern.mobilesdk.model.LangAdapter
import org.getlantern.mobilesdk.model.LocaleInfo
import java.util.*

class LanguageActivity : FragmentActivity() {
    private lateinit var languages: ArrayList<String>
    private lateinit var localeMap: MutableMap<String, Locale>

    private lateinit var binding: LanguagesBinding

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = LanguagesBinding.inflate(layoutInflater)
        setContentView(binding.root)

        val localeInfos = LocaleInfo.list(this)
        languages = ArrayList()
        localeMap = HashMap()
        for (localeInfo in localeInfos) {
            languages.add(localeInfo.label)
            localeMap[localeInfo.label] = localeInfo.locale
        }
        languages.sort()
        binding.list.apply {
            this.adapter = LanguageAdapter().apply {
                callback = object: LanguageAdapter.Callback {
                    override fun onClick(view: View, pos: Int, item: LanguageAdapterModel) {
                        setLocale(item.lang)
                    }
                }
                val current = LanternApp.getSession().language
                lang = languages.map {
                    LanguageAdapterModel(it, current == localeMap[it].toString())
                }
            }
            layoutManager = LinearLayoutManager(this@LanguageActivity)
            setHasFixedSize(true)
            addItemDecoration(object: RecyclerView.ItemDecoration() {
                override fun getItemOffsets(
                    outRect: Rect,
                    view: View,
                    parent: RecyclerView,
                    state: RecyclerView.State
                ) {
                    super.getItemOffsets(outRect, view, parent, state)
                    outRect.top = resources.getDimensionPixelSize(R.dimen.space_small)
                }
            })
        }
    }

    fun setLocale(lang: String) {
        val locale = localeMap[lang]
        Logger.debug(TAG, "Language selected: $lang setting locale to $locale")
        LanternApp.getSession().setLanguage(locale)
        val refresh = Intent(this, Launcher::class.java)
        refresh.action = "restart"
        refresh.addFlags(Intent.FLAG_ACTIVITY_NO_ANIMATION)
        startActivity(refresh)
        finish()
    }

    companion object {
        private val TAG = LanguageActivity::class.java.name
    }
}