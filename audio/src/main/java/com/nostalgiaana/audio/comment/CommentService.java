package com.nostalgiaana.audio.comment;

import com.nostalgiaana.audio.comment.dto.CommentResponse;
import com.nostalgiaana.audio.comment.dto.CreateCommentRequest;
import com.nostalgiaana.audio.content.Content;
import com.nostalgiaana.audio.content.ContentRepository;
import com.nostalgiaana.audio.user.User;
import com.nostalgiaana.audio.user.UserRole;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class CommentService {

    private final CommentRepository commentRepository;
    private final ContentRepository contentRepository;

    public List<CommentResponse> listByContent(UUID contentId, User requester) {
        Content content = findContentAndCheckAccess(contentId, requester);
        return commentRepository.findByContentIdOrderByCreatedAtAsc(content.getId()).stream()
                .map(this::toResponse)
                .toList();
    }

    public CommentResponse create(UUID contentId, CreateCommentRequest request, User author) {
        Content content = findContentAndCheckAccess(contentId, author);

        Comment comment = Comment.builder()
                .content(content)
                .user(author)
                .text(request.getText())
                .build();

        comment = commentRepository.save(comment);

        return toResponse(comment);
    }

    // Mirrors ContentService.getStreamUrl's premium gate — reading or posting
    // comments on premium-only content must be exactly as restricted as
    // streaming it, otherwise a LISTENER could read/post around the paywall.
    private Content findContentAndCheckAccess(UUID contentId, User requester) {
        Content content = contentRepository.findById(contentId)
                .orElseThrow(() -> new RuntimeException("Content not found"));

        if (Boolean.TRUE.equals(content.getIsPremium()) && requester.getRole() == UserRole.LISTENER) {
            throw new RuntimeException("Premium content requires subscription");
        }

        return content;
    }

    private CommentResponse toResponse(Comment comment) {
        User author = comment.getUser();
        return CommentResponse.builder()
                .id(comment.getId())
                .authorId(author != null ? author.getId() : null)
                .authorName(author != null ? (author.getFirstName() + " " + author.getLastName()) : null)
                .text(comment.getText())
                .createdAt(comment.getCreatedAt())
                .build();
    }
}
