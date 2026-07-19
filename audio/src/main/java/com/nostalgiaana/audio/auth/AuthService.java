package com.nostalgiaana.audio.auth;

import com.nostalgiaana.audio.auth.dto.AuthResponse;
import com.nostalgiaana.audio.auth.dto.LoginRequest;
import com.nostalgiaana.audio.auth.dto.SignupRequest;
import com.nostalgiaana.audio.exception.AccountSuspendedException;
import com.nostalgiaana.audio.exception.UserNotApprovedException;
import com.nostalgiaana.audio.storage.StorageService;
import com.nostalgiaana.audio.user.User;
import com.nostalgiaana.audio.user.UserRole;
import com.nostalgiaana.audio.user.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuthService {

    private final UserService userService;
    private final JwtService jwtService;
    private final PasswordEncoder passwordEncoder;
    private final StorageService storageService;

    public AuthResponse signup(SignupRequest request, MultipartFile profilePicture) {

        if (request.getPhone() == null) {
            throw new RuntimeException("Phone number is required");
        }

        // Check if phone already exists
        if (request.getPhone() != null && userService.existsByPhone(request.getPhone())) {
            throw new RuntimeException("Phone number already registered");
        }

        if (profilePicture != null && !profilePicture.isEmpty()) {
            String declaredType = profilePicture.getContentType();
            if (declaredType == null || !declaredType.startsWith("image/")) {
                throw new RuntimeException("Profile picture must be an image file, got: " + declaredType);
            }
        }

        // Build new user
        User user = User.builder()
                .firstName(request.getFirstName())
                .lastName(request.getLastName())
                .phone(request.getPhone())
                .country(request.getCountry())
                .city(request.getCity())
                .passwordHash(passwordEncoder.encode(request.getPassword()))
                .role(UserRole.LISTENER)
                .build();

        User savedUser = userService.save(user);

        if (profilePicture != null && !profilePicture.isEmpty()) {
            String pictureKey = savedUser.getId() + extensionOf(profilePicture.getOriginalFilename());
            storageService.uploadMultipartFile(storageService.getProfilePicturesBucket(), pictureKey, profilePicture);
            savedUser.setProfilePicPath(pictureKey);
            savedUser = userService.save(savedUser);
        }

        // Generate tokens
        String accessToken = jwtService.generateAccessToken(
                savedUser.getId(),
                savedUser.getRole().name()
        );

        String refreshToken = jwtService.generateRefreshToken(savedUser.getId());

        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .userId(savedUser.getId())
                .firstName(savedUser.getFirstName())
                .lastName(savedUser.getLastName())
                .phone(savedUser.getPhone())
                .role(savedUser.getRole())
                .membershipStatus("STANDARD")
                .build();
    }

    public AuthResponse login(LoginRequest request) {

        String identifier = request.getIdentifier();

        User user = userService.findByIdentifier(identifier)
                .orElseThrow(() -> new RuntimeException("User not found"));

        if (!passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            throw new RuntimeException("Invalid password");
        }

        if (!user.getIsActive()) {
            throw new AccountSuspendedException("Account is suspended");
        }

        if (!user.getApproved()) {
            throw new UserNotApprovedException("waiting for approval for this mobile number");
        }

        String accessToken = jwtService.generateAccessToken(
                user.getId(),
                user.getRole().name()
        );

        String refreshToken = jwtService.generateRefreshToken(user.getId());

        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .userId(user.getId())
                .firstName(user.getFirstName())
                .lastName(user.getLastName())
                .phone(user.getPhone())
                .role(user.getRole())
                .membershipStatus(user.getRole() == UserRole.PREMIUM ? "PREMIUM" : "STANDARD")
                .build();
    }

    private String extensionOf(String originalFilename) {
        if (originalFilename == null) {
            return "";
        }
        int dotIndex = originalFilename.lastIndexOf('.');
        return dotIndex >= 0 ? originalFilename.substring(dotIndex) : "";
    }
}
