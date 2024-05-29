package org.getlantern.lantern.model;

public class UserStatus {
    private final boolean status;
    private final long monthsLeft;

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
