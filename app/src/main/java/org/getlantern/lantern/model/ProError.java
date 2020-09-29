package org.getlantern.lantern.model;

import androidx.annotation.NonNull;

import com.google.gson.JsonObject;

public class ProError {

    private String id;
    private String message;
    private JsonObject details;

    public ProError(@NonNull final String id, @NonNull final String message) {
        this.id = id;
        this.message = message;
    }

    public ProError(@NonNull final JsonObject result) {
        if (result.get("errorId") != null) {
            this.id = result.get("errorId").getAsString();
        }
        if (result.get("error") != null) {
            this.message = result.get("error").getAsString();
        }
        if (result.get("details") != null) {
            this.details = result.get("details").getAsJsonObject();
        }
    }

    public String getMessage() {
        return message;
    }

    public String getId() {
        return id;
    }

    public JsonObject getDetails() {
        return details;
    }

    public String toString() {
        return String.format("Error; id=%s message=%s", id, message);
    }
}
