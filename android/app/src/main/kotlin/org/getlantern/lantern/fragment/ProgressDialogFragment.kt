package org.getlantern.lantern.fragment

import android.app.Dialog
import android.app.ProgressDialog
import android.os.Bundle
import androidx.annotation.NonNull
import androidx.fragment.app.DialogFragment

open class ProgressDialogFragment : DialogFragment() {

    @NonNull
    override fun onCreateDialog(savedInstanceState: Bundle?): Dialog {
        val msgId: Int? = arguments?.getInt("msgId")
        val dialog = ProgressDialog(requireContext())
        if (msgId != null) dialog.setMessage(getString(msgId))
        return dialog
    }

    companion object {
        @JvmStatic
        fun newInstance(msgId: Int): ProgressDialogFragment {
            val fragment = ProgressDialogFragment()
            val args: Bundle = Bundle()
            args.putInt("msgId", msgId)
            fragment.setArguments(args)
            return fragment
        }
    }
}
