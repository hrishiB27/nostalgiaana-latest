package com.nostalgiaana.audio.comment;

import com.nostalgiaana.audio.comment.dto.CommentResponse;
import com.nostalgiaana.audio.comment.dto.CreateCommentRequest;
import com.nostalgiaana.audio.content.Content;
import com.nostalgiaana.audio.content.ContentRepository;
import com.nostalgiaana.audio.user.User;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class CommentService {

    private final CommentRepository commentRepository;
    private final ContentRepository contentRepository;

    public List<CommentResponse> listByContent(UUID contentId) {
        return commentRepository.findByContentIdOrderByCreatedAtAsc(contentId).stream()
                .map(this::toResponse)
                .toList();
    }

    public CommentResponse create(UUID contentId, CreateCommentRequest request, User author) {
        Content content = contentRepository.findById(contentId)
                .orElseThrow(() -> new RuntimeException("Content not found"));

        Comment comment = Comment.builder()
                .content(content)
                .user(author)
                .text(request.getText())
                .build();

        comment = commentRepository.save(comment);

        return toResponse(comment);
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
