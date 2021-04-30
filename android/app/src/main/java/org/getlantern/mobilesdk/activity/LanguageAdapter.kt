package org.getlantern.mobilesdk.activity

import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import org.getlantern.lantern.databinding.ItemLanguageBinding

data class LanguageAdapterModel(val lang: String, var isSelected: Boolean)
class LanguageAdapter : RecyclerView.Adapter<LanguageAdapter.ViewHolder>() {
    var callback: Callback? = null
    var lang: List<LanguageAdapterModel> = emptyList()
        set(value) {
            field = value
            notifyDataSetChanged()
        }
    private var selectedPos = -1

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolder {
        return ViewHolder(
            ItemLanguageBinding.inflate(LayoutInflater.from(parent.context), parent, false)
        ).apply {
            itemView.setOnClickListener { view ->
                val pos = bindingAdapterPosition
                if (pos >= 0) {
                    getItem(pos).let {
                        if (selectedPos >= 0) {
                            lang[selectedPos].isSelected = false
                            notifyItemChanged(selectedPos)
                        }
                        selectedPos = pos
                        lang[selectedPos].isSelected = true
                        notifyItemChanged(selectedPos)
                        callback?.onClick(view, pos, it)
                    }
                }
            }
        }
    }

    override fun onBindViewHolder(holder: ViewHolder, position: Int) {
        val item = getItem(position)
        holder.bind(item, position)
    }

    private fun getItem(pos: Int) = lang[pos]

    interface Callback {
        fun onClick(view: View, pos: Int, item: LanguageAdapterModel)
    }

    inner class ViewHolder(val binding: ItemLanguageBinding) : RecyclerView.ViewHolder(binding.root) {
        fun bind(item: LanguageAdapterModel, position: Int) {
            binding.radioButton.text = item.lang
            binding.radioButton.isChecked = item.isSelected
        }
    }

    override fun getItemCount(): Int {
        return lang.size
    }
}