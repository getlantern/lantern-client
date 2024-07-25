//package org.getlantern.mobilesdk.model
//
//import android.content.Context
//import org.getlantern.lantern.R
//import java.text.Collator
//import java.util.Locale
//
//class LocaleInfo(var label: String, val language: String, var country: String) :
//    Comparable<LocaleInfo> {
//
//    val locale: Locale by lazy {
//        Locale(language, country)
//    }
//
//    constructor(context: Context, locale: Locale) : this(
//        getDisplayName(context, locale),
//        locale.language,
//        locale.country
//    )
//
//    constructor(context: Context, locale: String) : this(
//        context,
//        Locale(locale.substring(0, 2), locale.substring(3, 5))
//    )
//
//    override fun toString(): String {
//        return label
//    }
//
//    override fun compareTo(other: LocaleInfo): Int {
//        return sCollator.compare(label, other.label)
//    }
//
//    companion object {
//        val sCollator = Collator.getInstance()
//
//        private fun getDisplayName(context: Context, l: Locale): String {
//            val code = l.toString()
//            val specialLocaleCodes = context.resources.getStringArray(R.array.special_locale_codes)
//            val specialLocaleNames = context.resources.getStringArray(R.array.special_locale_names)
//            for (i in specialLocaleCodes.indices) {
//                if (specialLocaleCodes[i] == code) {
//                    return specialLocaleNames[i]
//                }
//            }
//            return toTitleCase(l.getDisplayLanguage(l))
//        }
//
//        private fun toTitleCase(s: String): String {
//            return if (s.isEmpty()) s else Character.toUpperCase(s[0]).toString() + s.substring(1)
//        }
//    }
//}
