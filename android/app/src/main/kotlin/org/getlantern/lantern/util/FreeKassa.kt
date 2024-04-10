package org.getlantern.lantern.util

import android.net.Uri
import java.math.BigInteger
import java.security.MessageDigest
import java.util.Locale

class FreeKassa {
    companion object {
        private fun validateValueOrPickDefault(
            v: String,
            arr: List<String>,
            default: String,
        ): String {
            for (i in arr) {
                if (i == v) {
                    return v
                }
            }
            return default
        }

        @JvmStatic
        fun getPayURI(
            merchantId: Int,
            amount: Long,
            currency: String = "RUB",
            orderId: String,
            secretWordOne: String,
            lang: String,
            email: String,
            additionalParams: Map<String, String> = mapOf(),
        ): Uri {
            val validatedCurrency = validateValueOrPickDefault(
                currency.uppercase(Locale.getDefault()),
                ACCEPTED_CURRENCIES,
                "RUB",
            )
            val validatedLanguage = validateValueOrPickDefault(
                lang.lowercase(Locale.getDefault()),
                ACCEPTED_LANGUAGES,
                "ru",
            )
            // API docs:
            // https://docs.freekassa.ru/#section/1.-Vvedenie/1.3.-Nastrojka-formy-oplaty
            return Uri.parse("https://pay.freekassa.ru/")
                .buildUpon()
                .appendQueryParameter("m", merchantId.toString())
                .appendQueryParameter("oa", amount.toString())
                .appendQueryParameter(
                    "currency",
                    validatedCurrency,
                )
                .appendQueryParameter("o", orderId)
                .appendQueryParameter(
                    "s",
                    makeSignature(merchantId, validatedCurrency, amount, secretWordOne, orderId),
                )
                .appendQueryParameter(
                    "language",
                    validatedLanguage,
                )
                .appendQueryParameter(
                    "em",
                    email,
                )
                .apply {
                    // Freekassa allows "pass-through" parameters that the client can specify
                    // that Freekassa will just pass-through to the S2S callback (i.e., this
                    // handler). They must be prefixed with `us_`.
                    // https://docs.freekassa.ru/#section/1.-Vvedenie/1.3.-Nastrojka-formy-oplaty
                    for ((key, value) in additionalParams) {
                        appendQueryParameter("us_$key", value)
                    }
                }
                .build()
        }

        private fun makeSignature(
            merchantId: Int,
            currency: String,
            amount: Long,
            secretWordOne: String,
            orderId: String,
        ): String {
            val md = MessageDigest.getInstance("MD5")
            val s = "$merchantId:$amount:$secretWordOne:$currency:$orderId"
            val digest = md.digest(s.toByteArray())
            return String.format("%032x", BigInteger(1, digest))
        }

        private val ACCEPTED_LANGUAGES = listOf("ru", "en")
        private val ACCEPTED_CURRENCIES = listOf("RUB", "USD", "EUR", "UAH", "KZT")
    }
}
