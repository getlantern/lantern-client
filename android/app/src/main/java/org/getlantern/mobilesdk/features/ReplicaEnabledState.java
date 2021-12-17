package org.getlantern.mobilesdk.features;

// See 'Enabling Replica' section in the README for more info
public enum ReplicaEnabledState {
    YES(0), // Always enabled, regardless of what global config says
    NO(1), // Always disabled, regardless of what global config says
    GLOBAL_CONFIG(2); // Depends on global config

    private final long value;

    private ReplicaEnabledState(long value) {
        this.value = value;
    }

    public long getValue() {
        return value;
    }
}
