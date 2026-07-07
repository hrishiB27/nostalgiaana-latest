package com.nostalgiaana.audio.admin;

import com.nostalgiaana.audio.admin.dto.AdminUserResponse;
import com.nostalgiaana.audio.content.ContentService;
import com.nostalgiaana.audio.content.ContentType;
import com.nostalgiaana.audio.content.dto.ContentDetailResponse;
import com.nostalgiaana.audio.content.dto.ContentResponse;
import com.nostalgiaana.audio.content.dto.ContentUploadRequest;
import com.nostalgiaana.audio.user.User;
import com.nostalgiaana.audio.user.UserRole;
import com.nostalgiaana.audio.user.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AdminService {

    private final ContentService contentService;
    private final UserService userService;

    // ---- Shows ----

    public ContentResponse createShow(ContentUploadRequest request, MultipartFile video,
                                       MultipartFile thumbnail, User admin) {
        return contentService.upload(ContentType.SHOW, request, video, thumbnail, admin);
    }

    public List<ContentDetailResponse> listShows() {
        return contentService.listDetailedByType(ContentType.SHOW);
    }

    public ContentDetailResponse updateShow(UUID id, ContentUploadRequest request, MultipartFile thumbnail) {
        return contentService.updateMetadata(id, ContentType.SHOW, request, thumbnail);
    }

    public void deleteShow(UUID id) {
        contentService.delete(id, ContentType.SHOW);
    }

    // ---- Audios ----

    public ContentResponse createAudio(ContentUploadRequest request, MultipartFile audio,
                                        MultipartFile thumbnail, User admin) {
        return contentService.upload(ContentType.AUDIO, request, audio, thumbnail, admin);
    }

    public List<ContentDetailResponse> listAudios() {
        return contentService.listDetailedByType(ContentType.AUDIO);
    }

    public ContentDetailResponse updateAudio(UUID id, ContentUploadRequest request, MultipartFile thumbnail) {
        return contentService.updateMetadata(id, ContentType.AUDIO, request, thumbnail);
    }

    public void deleteAudio(UUID id) {
        contentService.delete(id, ContentType.AUDIO);
    }

    // ---- Users ----

    public List<AdminUserResponse> listUsers() {
        return userService.findAll().stream()
                .filter(user -> user.getRole() != UserRole.ADMIN)
                .map(this::toAdminUserResponse)
                .toList();
    }

    public void banUser(UUID id) {
        User user = userService.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found"));
        user.setIsActive(false);
        userService.save(user);
    }

    private AdminUserResponse toAdminUserResponse(User user) {
        return AdminUserResponse.builder()
                .id(user.getId())
                .firstName(user.getFirstName())
                .lastName(user.getLastName())
                .phone(user.getPhone())
                .country(user.getCountry())
                .city(user.getCity())
                .role(user.getRole())
                .membershipTier(user.getRole() == UserRole.PREMIUM ? "PREMIUM" : "STANDARD")
                .isActive(user.getIsActive())
                .createdAt(user.getCreatedAt())
                .build();
    }
}
