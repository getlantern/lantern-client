package org.getlantern.mobilesdk.model

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ArrayAdapter
import android.widget.TextView
import org.getlantern.lantern.LanternApp
import org.getlantern.lantern.R
import java.util.Locale

// TODO <10-05-22, kalli> : this is not used
class LangAdapter(context: Context?, lang: List<String>, val localeMap: Map<String, Locale>) : ArrayAdapter<String>(context!!, 0, lang) {
    override fun getView(position: Int, _convertView: View?, parent: ViewGroup): View {
        var convertView = _convertView
        val lang = getItem(position)
        val current = LanternApp.getSession().language
        var color = context.resources.getColor(R.color.black)
        val entry = localeMap[lang]
        if (entry != null && entry.toString() == current) {
            // the current locale should be highlighted the selected color
            color = context.resources.getColor(R.color.selected_item)
        }

        // Check if an existing view is being reused, otherwise inflate the view
        if (convertView == null) {
            convertView = LayoutInflater.from(context).inflate(R.layout.language_item, parent, false)
        }
        val tv = convertView!!.findViewById<View>(R.id.title) as TextView
        tv.text = lang
        tv.setTextColor(color)

        // Return the completed view to render on screen
        return convertView
    }

    companion object {
        private val TAG = LangAdapter::class.java.name
    }
}
