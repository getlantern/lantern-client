package org.getlantern.lantern.model;

public class AccountInitializationStatus {

    private AccountInitializationStatus.Status status;

    public enum Status {
        PROCESSING, SUCCESS, FAILURE;
    }

    public AccountInitializationStatus(final AccountInitializationStatus.Status status) {
        this.status = status;
    }

    public AccountInitializationStatus.Status getStatus() {
        return status;
    }

    public boolean isProcessing() {
        return status != null && status.equals(Status.PROCESSING);
    }

    public boolean isSuccess() {
        return status != null && status.equals(Status.SUCCESS);
    }

    public boolean isFailure() {
        return status != null && status.equals(Status.FAILURE);
    }

}
