package com.nostalgiaana.audio.auth;

import com.nostalgiaana.audio.auth.dto.AuthResponse;
import com.nostalgiaana.audio.auth.dto.LoginRequest;
import com.nostalgiaana.audio.auth.dto.OtpChallengeResponse;
import com.nostalgiaana.audio.auth.dto.SignupRequest;
import com.nostalgiaana.audio.auth.dto.VerifyOtpRequest;
import com.nostalgiaana.audio.exception.UserNotApprovedException;
import com.nostalgiaana.audio.storage.StorageService;
import com.nostalgiaana.audio.user.User;
import com.nostalgiaana.audio.user.UserRole;
import com.nostalgiaana.audio.user.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.security.SecureRandom;
import java.time.Duration;
import java.util.UUID;

@Service
@RequiredArgsConstructor
@Slf4j
public class AuthService {

    private static final Duration OTP_TTL = Duration.ofMinutes(5);
    private static final int MAX_OTP_ATTEMPTS = 5;
    private static final SecureRandom SECURE_RANDOM = new SecureRandom();

    private final UserService userService;
    private final JwtService jwtService;
    private final PasswordEncoder passwordEncoder;
    private final StringRedisTemplate redisTemplate;
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

    public OtpChallengeResponse login(LoginRequest request) {

        String identifier = request.getIdentifier();

        User user = userService.findByIdentifier(identifier)
                .orElseThrow(() -> new RuntimeException("User not found"));

        if (!passwordEncoder.matches(request.getPassword(), user.getPasswordHash())) {
            throw new RuntimeException("Invalid password");
        }

        if (!user.getIsActive()) {
            throw new RuntimeException("Account is suspended");
        }

        if (!user.getApproved()) {
            throw new UserNotApprovedException("waiting for approval for this mobile number");
        }

        String otp = generateOtp();
        redisTemplate.opsForValue().set(otpKey(identifier), otp, OTP_TTL);
        redisTemplate.delete(otpAttemptsKey(identifier));

        log.info("[SMS/WhatsApp OTP Fallback] Sending OTP: {} to phone number: {}", otp, identifier);

        return OtpChallengeResponse.builder()
                .message("OTP sent")
                .preAuthToken(UUID.randomUUID().toString())
                .identifier(identifier)
                .expiresInSeconds(OTP_TTL.toSeconds())
                .build();
    }

    public AuthResponse verifyOtp(VerifyOtpRequest request) {

        String identifier = request.getIdentifier();

        Long attempts = redisTemplate.opsForValue().increment(otpAttemptsKey(identifier));
        redisTemplate.expire(otpAttemptsKey(identifier), OTP_TTL);
        if (attempts != null && attempts > MAX_OTP_ATTEMPTS) {
            redisTemplate.delete(otpKey(identifier));
            throw new RuntimeException("Too many attempts, request a new OTP");
        }

        String storedOtp = redisTemplate.opsForValue().get(otpKey(identifier));
        if (storedOtp == null) {
            throw new RuntimeException("OTP expired or not requested");
        }

        if (!storedOtp.equals(request.getOtp())) {
            throw new RuntimeException("Invalid OTP");
        }

        redisTemplate.delete(otpKey(identifier));
        redisTemplate.delete(otpAttemptsKey(identifier));

        User user = userService.findByIdentifier(identifier)
                .orElseThrow(() -> new RuntimeException("User not found"));

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

    private String generateOtp() {
        return String.format("%06d", SECURE_RANDOM.nextInt(1_000_000));
    }

    private String otpKey(String identifier) {
        return "otp:" + identifier;
    }

    private String otpAttemptsKey(String identifier) {
        return "otp:attempts:" + identifier;
    }

    private String extensionOf(String originalFilename) {
        if (originalFilename == null) {
            return "";
        }
        int dotIndex = originalFilename.lastIndexOf('.');
        return dotIndex >= 0 ? originalFilename.substring(dotIndex) : "";
    }
}
