package com.nostalgiaana.audio.auth.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class OtpChallengeResponse {

    private String message;
    private String preAuthToken;
    private String identifier;
    private long expiresInSeconds;
}
