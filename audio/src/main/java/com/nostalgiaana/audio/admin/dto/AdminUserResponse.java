package com.nostalgiaana.audio.admin.dto;

import com.nostalgiaana.audio.user.UserRole;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AdminUserResponse {

    private UUID id;
    private String firstName;
    private String lastName;
    private String phone;
    private String country;
    private String city;
    private UserRole role;
    private String membershipTier;
    private Boolean isActive;
    private LocalDateTime createdAt;
}
