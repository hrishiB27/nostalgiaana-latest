package com.nostalgiaana.audio.auth;

import com.nostalgiaana.audio.auth.dto.AuthResponse;
import com.nostalgiaana.audio.auth.dto.LoginRequest;
import com.nostalgiaana.audio.auth.dto.SignupRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping(value = "/signup", consumes = "multipart/form-data")
    public ResponseEntity<AuthResponse> signup(
            @Valid @RequestPart("data") SignupRequest request,
            @RequestPart(value = "profilePicture", required = false) MultipartFile profilePicture) {
        return ResponseEntity.ok(authService.signup(request, profilePicture));
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        return ResponseEntity.ok(authService.login(request));
    }
}
