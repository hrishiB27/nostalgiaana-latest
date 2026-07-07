package com.nostalgiaana.audio.content;

import com.nostalgiaana.audio.content.dto.ContentResponse;
import com.nostalgiaana.audio.content.dto.StreamUrlResponse;
import com.nostalgiaana.audio.user.User;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/content")
@RequiredArgsConstructor
public class ContentController {

    private final ContentService contentService;

    @GetMapping("/shows")
    public ResponseEntity<List<ContentResponse>> listShows(
            @RequestParam(required = false) UUID categoryId) {
        return ResponseEntity.ok(contentService.listByType(ContentType.SHOW, categoryId));
    }

    @GetMapping("/audios")
    public ResponseEntity<List<ContentResponse>> listAudios(
            @RequestParam(required = false) UUID categoryId) {
        return ResponseEntity.ok(contentService.listByType(ContentType.AUDIO, categoryId));
    }

    @GetMapping("/{id}/stream")
    public ResponseEntity<StreamUrlResponse> stream(
            @PathVariable UUID id,
            @AuthenticationPrincipal User currentUser) {
        return ResponseEntity.ok(contentService.getStreamUrl(id, currentUser));
    }
}
