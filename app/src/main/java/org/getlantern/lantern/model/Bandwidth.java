package org.getlantern.lantern.model;

public class Bandwidth {
    private Long percent;
    private Long remaining;
    private Long allowed;

    public Bandwidth(Long percent, Long remaining, Long allowed) {
        this.percent = percent;
        this.remaining = remaining;
        this.allowed = allowed;
    }

    public Long getPercent() {
        return percent;
    }

    public Long getUsed() {
        return allowed - remaining;
    }

    public Long getRemaining() {
        return remaining;
    }

    public Long getAllowed() {
        return allowed;
    }

    public String toString() {
        return String.format("Bandwidth update: %d/%d (%d)",
                remaining, allowed, percent);
    }
}
