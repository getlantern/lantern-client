package org.lantern.app.model;

public class VpnState {

    private boolean useVpn;

    public VpnState(boolean useVpn) {
        this.useVpn = useVpn;
    }

    public boolean use() {
        return useVpn;
    }
}
