package com.nostalgiaana.audio.comment;

import com.nostalgiaana.audio.comment.dto.CommentResponse;
import com.nostalgiaana.audio.comment.dto.CreateCommentRequest;
import com.nostalgiaana.audio.user.User;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

// No SecurityConfig entry needed — everything under /api/content/** already
// requires authentication by default (see SecurityConfig's anyRequest().authenticated()),
// same as ContentController's shows/audios/stream endpoints.
@RestController
@RequestMapping("/api/content/{contentId}/comments")
@RequiredArgsConstructor
public class CommentController {

    private final CommentService commentService;

    @GetMapping
    public ResponseEntity<List<CommentResponse>> list(@PathVariable UUID contentId) {
        return ResponseEntity.ok(commentService.listByContent(contentId));
    }

    @PostMapping
    public ResponseEntity<CommentResponse> create(
            @PathVariable UUID contentId,
            @Valid @RequestBody CreateCommentRequest request,
            @AuthenticationPrincipal User currentUser) {
        return ResponseEntity.ok(commentService.create(contentId, request, currentUser));
    }
}
