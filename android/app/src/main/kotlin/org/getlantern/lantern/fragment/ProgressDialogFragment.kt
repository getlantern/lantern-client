package org.getlantern.lantern.fragment

import android.app.Dialog
import android.app.ProgressDialog
import android.os.Bundle
import androidx.annotation.NonNull
import androidx.fragment.app.DialogFragment

class ProgressDialogFragment : DialogFragment() {

    @NonNull
    override fun onCreateDialog(savedInstanceState:Bundle?):Dialog {
        val msgId:Int? = getArguments()?.getInt("msgId")
        val dialog = ProgressDialog(requireContext())
        if (msgId != null) dialog.setMessage(getString(msgId))
        return dialog
    }

    companion object {
        fun newInstance(msgId:Int):ProgressDialogFragment {
            val fragment = ProgressDialogFragment()
            val args:Bundle = Bundle()
            args.putInt("msgId", msgId)
            fragment.setArguments(args)
            return fragment
        }
    }
}