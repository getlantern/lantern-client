package org.getlantern.mobilesdk.activity

import android.content.Intent
import android.os.Bundle
import android.widget.ListView
import androidx.fragment.app.FragmentActivity
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.activity.Launcher
import org.getlantern.lantern.databinding.LanguagesBinding
import org.getlantern.mobilesdk.Logger
import org.getlantern.mobilesdk.model.LangAdapter
import org.getlantern.mobilesdk.model.LocaleInfo
import java.util.*

class LanguageActivity : FragmentActivity() {
    private lateinit var languages: ArrayList<String>
    private lateinit var localeMap: MutableMap<String, Locale>
    private lateinit var adapter: LangAdapter

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
        adapter = LangAdapter(this, languages, localeMap)
        binding.list.adapter = adapter
        binding.list.choiceMode = ListView.CHOICE_MODE_SINGLE
        binding.list.setOnItemClickListener { _, _, _, id  -> setLocale(languages[id.toInt()]) }
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