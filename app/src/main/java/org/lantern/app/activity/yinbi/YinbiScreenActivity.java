package org.lantern.app.activity.yinbi;

import android.os.Bundle;
import android.content.Context;
import android.content.Intent;
import android.widget.TextView;

import org.lantern.app.R;
import org.lantern.app.fragment.ClickSpan;
import org.lantern.app.model.Utils;
import org.lantern.app.activity.WebViewActivity_;

public class YinbiScreenActivity extends YinbiActivity {
    private static final String TAG = YinbiScreenActivity.class.getName();

    private final ClickSpan.OnClickListener clickSpan =
        new ClickSpan.OnClickListener() {
            @Override
            public void onClick() {
                final Intent intent = new Intent(YinbiScreenActivity.this,
                        WebViewActivity_.class);
                intent.putExtra("url", YINBI_WEBSITE);
                startActivity(intent);
            }
        };


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if (!session.isProUser()) {
            renewPro.setText(getResources().getString(R.string.buy_pro_get_yinbi));
            yinbiDesc.setText(getResources().getString(R.string.lantern_partnered_yinbi_free));
        } else {
            yinbiDesc.setText(getResources().getString(R.string.lantern_partnered_yinbi_pro));
        }
        highlightWebsite(clickSpan, yinbiDesc);
    }

    @Override
    public int getLayoutId() {
        return R.layout.yinbi_screen;
    }
}
