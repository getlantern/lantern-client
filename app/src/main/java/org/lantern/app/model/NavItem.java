package org.lantern.app.model;

import android.content.res.Resources;
import org.lantern.app.R;

public class NavItem {
    private int id;
    private String title;
    private int icon;

    public NavItem(final int id, final String title, final int icon) {
        this.id = id;
        this.title = title;
        this.icon = icon;
    }

    public int getId() {
        return id;
    }

    public String getTitle() {
        return title;
    }

    public int getIcon() {
        return icon;
    }

    public void setTitle(String title) {
        this.title = title;
    }
}
