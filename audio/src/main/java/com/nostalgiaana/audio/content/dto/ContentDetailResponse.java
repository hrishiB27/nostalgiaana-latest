package com.nostalgiaana.audio.content.dto;

import com.nostalgiaana.audio.content.ContentType;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.UUID;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ContentDetailResponse {

    private UUID id;
    private String title;
    private String description;
    private ContentType contentType;
    private UUID categoryId;
    private String categoryName;
    private String speaker;
    private Integer durationSeconds;
    private Boolean isPremium;
    private Long playCount;
    private LocalDateTime uploadDate;
    private String rawAudioPath;
    private String rawVideoPath;
    private String coverPath;
    private String coverUrl;
    private String hlsManifestPath;
    private UUID uploadedByUserId;
    private String uploadedByName;
}
