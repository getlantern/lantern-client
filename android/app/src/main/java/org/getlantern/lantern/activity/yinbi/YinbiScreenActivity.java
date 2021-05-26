package org.getlantern.lantern.activity.yinbi;

import android.content.Intent;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import org.getlantern.lantern.LanternApp;
import org.getlantern.lantern.R;
import org.getlantern.lantern.activity.WebViewActivity_;
import org.getlantern.lantern.fragment.ClickSpan;
import org.getlantern.lantern.fragment.TitleBar;
import org.jetbrains.annotations.NotNull;

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
    public void onAttachFragment(@NonNull @NotNull Fragment fragment) {
        super.onAttachFragment(fragment);
        if (fragment instanceof TitleBar) {
            if (LanternApp.getSession().isProUser()) {
                ((TitleBar) fragment).setTitle(getString(R.string.yinbi_title_pro));
            } else {
                ((TitleBar) fragment).setTitle(getString(R.string.yinbi_title_free));
            }
        }
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if (!LanternApp.getSession().isProUser()) {
            renewPro.setText(getResources().getString(R.string.upgrade_to_pro_get_yinbi));
            yinbiDesc.setText(getResources().getString(R.string.yinbi_description_free));
        } else {
            renewPro.setText(getResources().getString(R.string.renew_pro_get_yinbi));
            yinbiDesc.setText(getResources().getString(R.string.yinbi_description_pro));
        }
        highlightWebsite(clickSpan, yinbiDesc);
    }

    @Override
    public int getLayoutId() {
        return R.layout.yinbi_screen;
    }
}
