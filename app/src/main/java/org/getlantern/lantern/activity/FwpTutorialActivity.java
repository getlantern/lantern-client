package org.getlantern.lantern.activity;

import android.content.ContentResolver;
import android.content.Context;
import android.net.Uri;
import androidx.fragment.app.FragmentActivity;
import androidx.annotation.AnyRes;
import androidx.annotation.NonNull;
import android.view.View;
import android.widget.ImageView;

import org.androidannotations.annotations.AfterViews;
import org.androidannotations.annotations.EActivity;
import org.androidannotations.annotations.ViewById;
import org.getlantern.lantern.R;
import com.github.piasy.biv.view.BigImageView;

import org.getlantern.mobilesdk.Lantern;

@EActivity(R.layout.fwp_tutorial)
public class FwpTutorialActivity extends FragmentActivity {

    private static final String TAG = FwpTutorialActivity.class.getName();

    @ViewById
    ImageView close;

    @ViewById
    BigImageView tutorialImage;

    @AfterViews
    void afterViews() {
        Lantern.sendEvent(this, "fwp_tutorial_view");
        tutorialImage.showImage(getUriToDrawable(this, R.drawable.tutorial_image_farsi));
    }

    private static final Uri getUriToDrawable(@NonNull Context context,
            @AnyRes int drawableId) {
            Uri imageUri = Uri.parse(ContentResolver.SCHEME_ANDROID_RESOURCE +
                    "://" + context.getResources().getResourcePackageName(drawableId)
                    + '/' + context.getResources().getResourceTypeName(drawableId)
                    + '/' + context.getResources().getResourceEntryName(drawableId) );
            return imageUri;
    }

    public void close(View view) {
        this.finish();
    }


    @Override
    public void onBackPressed() {
        super.onBackPressed();
        this.finish();
    }
}
