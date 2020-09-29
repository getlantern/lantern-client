package org.lantern.app.model;

public class UserStatus {
    private boolean status;
    private long monthsLeft;

    public UserStatus(boolean status, long monthsLeft) {
        this.status = status;
        this.monthsLeft = monthsLeft;
    }

    public String monthsLeft() {
        return String.format("%dMO", monthsLeft);
    }

    public boolean isActive() {
        return status;
    }
}
