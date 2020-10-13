package org.getlantern.lantern.activity.yinbi;

import android.content.Intent;
import android.os.Bundle;

import org.getlantern.lantern.LanternApp;
import org.getlantern.lantern.R;
import org.getlantern.lantern.activity.WebViewActivity_;
import org.getlantern.lantern.fragment.ClickSpan;

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

        if (!LanternApp.getSession().isProUser()) {
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
