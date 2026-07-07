package com.nostalgiaana.audio.content;

import com.nostalgiaana.audio.category.Category;
import com.nostalgiaana.audio.user.User;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "content")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Content {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @Column(nullable = false)
    private String title;

    @Column(columnDefinition = "TEXT")
    private String description;

    @ManyToOne
    @JoinColumn(name = "category_id")
    private Category category;

    private String speaker;

    private Integer durationSeconds;

    private String coverPath;

    private String hlsManifestPath;

    private String rawAudioPath;

    private String rawVideoPath;

    @Enumerated(EnumType.STRING)
    @Column(name = "content_type", nullable = false)
    @Builder.Default
    private ContentType contentType = ContentType.AUDIO;

    @Builder.Default
    private Boolean isPremium = false;

    @Builder.Default
    private Long playCount = 0L;

    @ManyToOne
    @JoinColumn(name = "uploaded_by")
    private User uploadedBy;

    @Builder.Default
    private LocalDateTime uploadDate = LocalDateTime.now();
}
