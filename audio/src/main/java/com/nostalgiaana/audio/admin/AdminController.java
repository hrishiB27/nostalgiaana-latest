package com.nostalgiaana.audio.admin;

import com.nostalgiaana.audio.admin.dto.AdminUserResponse;
import com.nostalgiaana.audio.content.dto.ContentDetailResponse;
import com.nostalgiaana.audio.content.dto.ContentResponse;
import com.nostalgiaana.audio.content.dto.ContentUploadRequest;
import com.nostalgiaana.audio.user.User;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
public class AdminController {

    private final AdminService adminService;

    // ---- Shows (video) ----

    @PostMapping(value = "/shows", consumes = "multipart/form-data")
    public ResponseEntity<ContentResponse> createShow(
            @Valid @RequestPart("data") ContentUploadRequest request,
            @RequestPart("video") MultipartFile video,
            @RequestPart(value = "thumbnail", required = false) MultipartFile thumbnail,
            @AuthenticationPrincipal User currentUser) {
        return ResponseEntity.ok(adminService.createShow(request, video, thumbnail, currentUser));
    }

    @GetMapping("/shows")
    public ResponseEntity<List<ContentDetailResponse>> listShows() {
        return ResponseEntity.ok(adminService.listShows());
    }

    @PutMapping(value = "/shows/{id}", consumes = "multipart/form-data")
    public ResponseEntity<ContentDetailResponse> updateShow(
            @PathVariable UUID id,
            @Valid @RequestPart("data") ContentUploadRequest request,
            @RequestPart(value = "thumbnail", required = false) MultipartFile thumbnail) {
        return ResponseEntity.ok(adminService.updateShow(id, request, thumbnail));
    }

    @DeleteMapping("/shows/{id}")
    public ResponseEntity<Void> deleteShow(@PathVariable UUID id) {
        adminService.deleteShow(id);
        return ResponseEntity.noContent().build();
    }

    // ---- Audios ----

    @PostMapping(value = "/audios", consumes = "multipart/form-data")
    public ResponseEntity<ContentResponse> createAudio(
            @Valid @RequestPart("data") ContentUploadRequest request,
            @RequestPart("audio") MultipartFile audio,
            @RequestPart(value = "thumbnail", required = false) MultipartFile thumbnail,
            @AuthenticationPrincipal User currentUser) {
        return ResponseEntity.ok(adminService.createAudio(request, audio, thumbnail, currentUser));
    }

    @GetMapping("/audios")
    public ResponseEntity<List<ContentDetailResponse>> listAudios() {
        return ResponseEntity.ok(adminService.listAudios());
    }

    @PutMapping(value = "/audios/{id}", consumes = "multipart/form-data")
    public ResponseEntity<ContentDetailResponse> updateAudio(
            @PathVariable UUID id,
            @Valid @RequestPart("data") ContentUploadRequest request,
            @RequestPart(value = "thumbnail", required = false) MultipartFile thumbnail) {
        return ResponseEntity.ok(adminService.updateAudio(id, request, thumbnail));
    }

    @DeleteMapping("/audios/{id}")
    public ResponseEntity<Void> deleteAudio(@PathVariable UUID id) {
        adminService.deleteAudio(id);
        return ResponseEntity.noContent().build();
    }

    // ---- Users ----

    @GetMapping("/users")
    public ResponseEntity<List<AdminUserResponse>> listUsers() {
        return ResponseEntity.ok(adminService.listUsers());
    }

    @DeleteMapping("/users/{id}")
    public ResponseEntity<Void> banUser(@PathVariable UUID id) {
        adminService.banUser(id);
        return ResponseEntity.noContent().build();
    }
}
