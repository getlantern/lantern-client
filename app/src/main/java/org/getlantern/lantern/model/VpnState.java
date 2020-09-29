package org.getlantern.lantern.model;

public class VpnState {

    private boolean useVpn;

    public VpnState(boolean useVpn) {
        this.useVpn = useVpn;
    }

    public boolean use() {
        return useVpn;
    }
}
