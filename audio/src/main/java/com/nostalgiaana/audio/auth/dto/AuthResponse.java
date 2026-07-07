package com.nostalgiaana.audio.auth.dto;

import com.nostalgiaana.audio.user.UserRole;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AuthResponse {

    private String accessToken;
    private String refreshToken;
    private UUID userId;
    private String firstName;
    private String lastName;
    private String phone;
    private UserRole role;
    private String membershipStatus;
}
