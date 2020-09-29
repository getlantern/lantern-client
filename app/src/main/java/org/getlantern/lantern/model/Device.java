package org.getlantern.lantern.model;

import com.google.gson.annotations.SerializedName;

public class Device {

    @SerializedName("id")
    private String id;

    @SerializedName("name")
    private String name;

    @SerializedName("created")
    private long created;

    public String getId() {
        return id;
    }

    public void setId(final String id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(final String name) {
        this.name = name;
    }

    public long getCreated() {
        return created;
    }

    public void setCreated(final long created) {
        this.created = created;
    }

    public String toString() {
        return String.format("ID: %s Name: %s", id, name);
    }
}
