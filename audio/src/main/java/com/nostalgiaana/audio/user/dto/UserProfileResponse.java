package com.nostalgiaana.audio.user.dto;

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
public class UserProfileResponse {

    private UUID id;
    private String firstName;
    private String lastName;
    private String phone;
    private UserRole role;
    private String membershipStatus;
}
