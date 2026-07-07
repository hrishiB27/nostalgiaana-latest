package com.nostalgiaana.audio.content;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

public interface ContentRepository extends JpaRepository<Content, UUID> {

    List<Content> findAllByOrderByUploadDateDesc();

    List<Content> findByContentTypeOrderByUploadDateDesc(ContentType contentType);

    List<Content> findByContentTypeAndCategoryIdOrderByUploadDateDesc(ContentType contentType, UUID categoryId);

    List<Content> findByIsPremiumFalseOrderByUploadDateDesc();

    List<Content> findByCategoryIdOrderByUploadDateDesc(UUID categoryId);

    List<Content> findTop10ByOrderByPlayCountDesc();

    List<Content> findTop6ByOrderByUploadDateDesc();

    @Query("SELECT c FROM Content c WHERE " +
           "LOWER(c.title) LIKE LOWER(CONCAT('%', :query, '%')) OR " +
           "LOWER(c.speaker) LIKE LOWER(CONCAT('%', :query, '%')) OR " +
           "LOWER(c.description) LIKE LOWER(CONCAT('%', :query, '%'))")
    List<Content> searchContent(String query);

    @Modifying
    @Transactional
    @Query("UPDATE Content c SET c.playCount = c.playCount + 1 WHERE c.id = :id")
    void incrementPlayCount(UUID id);
}
