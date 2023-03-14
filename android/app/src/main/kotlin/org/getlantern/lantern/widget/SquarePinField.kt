package org.getlantern.lantern.widget

import android.content.Context
import android.graphics.Canvas
import android.graphics.Paint
import android.os.Build
import android.util.AttributeSet
import org.getlantern.lantern.R
import org.getlantern.lantern.util.Util

class SquarePinField : PinField {

    private var cornerRadius = 0f
        set(value) {
            field = value
            invalidate()
        }

    private val cursorPadding = Util.dpToPx(5f)

    constructor(context: Context) : super(context)

    constructor(context: Context, attr: AttributeSet) : super(context, attr) {
        initParams(attr)
    }

    constructor(context: Context, attr: AttributeSet, defStyle: Int) : super(context, attr, defStyle) {
        initParams(attr)
    }

    private fun initParams(attr: AttributeSet) {
        val a = context.theme.obtainStyledAttributes(attr, R.styleable.SquarePinField, 0, 0)
        try {
            cornerRadius = a.getDimension(R.styleable.SquarePinField_cornerRadius, cornerRadius)
        } finally {
            a.recycle()
        }
    }

    override fun onDraw(canvas: Canvas) {
        for (i in 0 until numberOfFields) {
            val padding = distanceInBetween
            val paddedX1 = i * singleFieldWidth + padding * i
            val paddedX2 = paddedX1 + singleFieldWidth
            val paddedY1 = 0f
            val paddedY2 = height.toFloat()
            val textX = ((paddedX2 - paddedX1) / 2) + paddedX1
            val textY = ((paddedY2 - paddedY1) / 2 + paddedY1) + lineThickness + (textPaint.textSize / 4) + Util.dpToPx(4f)
            val character: Char? = getCharAt(i)

            drawRect(canvas, paddedX1, paddedY1, paddedX2, paddedY2, fieldBgPaint)

            if (highlightAllFields() && hasFocus()) {
                drawRect(canvas, paddedX1, paddedY1, paddedX2, paddedY2, highlightPaint)
            } else {
                drawRect(canvas, paddedX1, paddedY1, paddedX2, paddedY2, fieldPaint)
            }

            if (character != null) {
                canvas.drawText(character.toString(), textX, textY, textPaint)
            }

            if (shouldDrawHint()) {
                val hintChar = hint.getOrNull(i)
                if (hintChar != null) {
                    canvas.drawText(hintChar.toString(), textX, textY, hintPaint)
                }
            }

            if (hasFocus() && i == text?.length ?: 0) {
                if (isCursorEnabled) {
                    val cursorPadding = cursorPadding + highLightThickness
                    val cursorY1 = paddedY1 + cursorPadding
                    val cursorY2 = paddedY2 - cursorPadding
                    drawCursor(canvas, textX, cursorY1, cursorY2, highlightPaint)
                }
            }
            highlightLogic(i, text?.length) {
                drawRect(canvas, paddedX1, paddedY1, paddedX2, paddedY2, highlightPaint)
            }
        }
    }

    private fun drawRect(
        canvas: Canvas,
        paddedX1: Float,
        paddedY1: Float,
        paddedX2: Float,
        paddedY2: Float,
        paint: Paint
    ) {
        if (cornerRadius > 0 && Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            canvas.drawRoundRect(paddedX1, paddedY1, paddedX2, paddedY2, cornerRadius, cornerRadius, paint)
        } else {
            canvas.drawRect(paddedX1, paddedY1, paddedX2, paddedY2, paint)
        }
    }
}
