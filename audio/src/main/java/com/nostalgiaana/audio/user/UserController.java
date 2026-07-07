package com.nostalgiaana.audio.user;

import com.nostalgiaana.audio.user.dto.UserProfileResponse;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/user")
public class UserController {

    @GetMapping("/me")
    public ResponseEntity<UserProfileResponse> me(@AuthenticationPrincipal User currentUser) {
        return ResponseEntity.ok(UserProfileResponse.builder()
                .id(currentUser.getId())
                .firstName(currentUser.getFirstName())
                .lastName(currentUser.getLastName())
                .phone(currentUser.getPhone())
                .role(currentUser.getRole())
                .membershipStatus(currentUser.getRole() == UserRole.PREMIUM ? "PREMIUM" : "STANDARD")
                .build());
    }
}
