package com.nostalgiaana.audio.exception;

public class UserNotApprovedException extends RuntimeException {
    public UserNotApprovedException(String message) {
        super(message);
    }
}
