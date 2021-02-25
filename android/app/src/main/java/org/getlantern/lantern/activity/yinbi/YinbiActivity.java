package org.getlantern.lantern.activity.yinbi;

import android.app.ProgressDialog;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import androidx.core.content.ContextCompat;
import androidx.fragment.app.FragmentActivity;

import org.getlantern.lantern.LanternApp;
import org.getlantern.lantern.R;
import org.getlantern.lantern.fragment.ClickSpan;
import org.getlantern.lantern.model.LanternHttpClient;
import org.getlantern.lantern.model.Utils;

public abstract class YinbiActivity extends FragmentActivity {
    private static final String TAG = YinbiActivity.class.getName();

    protected static final String YINBI_WEBSITE = "https://yin.bi";
    protected static final String YINBI_SIGNUP = "https://yin.bi/register";
    protected static final String YINBI_LOGIN = "https://yin.bi/login";

    protected ProgressDialog dialog;
    protected Button renewPro;
    protected Button enterProCodes;

    protected TextView yinbiDesc;

    protected TextView visitYinbi;

    protected static final LanternHttpClient lanternClient = LanternApp.getLanternHttpClient();
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(getLayoutId());

        renewPro = (Button)findViewById(R.id.renewPro);
        enterProCodes = (Button)findViewById(R.id.enterProCodes);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            enterProCodes.setStateListAnimator(null);
        }
        yinbiDesc = (TextView)findViewById(R.id.yinbiDesc);
        visitYinbi = (TextView)findViewById(R.id.visitYinbi);

        renewPro.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                startActivity(new Intent(YinbiActivity.this, LanternApp.getSession().plansActivity()));
            }
        });
        enterProCodes.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                enterBulkProCodes(v);
            }
        });
    }

    protected void highlightWebsite(final ClickSpan.OnClickListener clickSpan, final TextView desc) {
        final int color = ContextCompat.getColor(this, R.color.pink);
        Utils.clickify(desc, getString(R.string.yinbi_website), color, clickSpan);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }

    private void enterBulkProCodes(View view) {
        lanternClient.openBulkProCodes(this);
    }

    /**
     * @return The layout id that's gonna be the activity view.
     */
    protected abstract int getLayoutId();


}
