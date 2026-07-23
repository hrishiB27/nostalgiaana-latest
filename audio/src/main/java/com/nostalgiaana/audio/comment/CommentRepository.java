package com.nostalgiaana.audio.comment;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.UUID;

public interface CommentRepository extends JpaRepository<Comment, UUID> {

    // JOIN FETCH the author so CommentService.toResponse()'s per-row
    // comment.getUser().getFirstName()/getLastName() doesn't N+1 —
    // c.content is deliberately not fetched since the response never reads it.
    @Query("SELECT c FROM Comment c JOIN FETCH c.user WHERE c.content.id = :contentId ORDER BY c.createdAt ASC")
    List<Comment> findByContentIdOrderByCreatedAtAsc(@Param("contentId") UUID contentId);
}
