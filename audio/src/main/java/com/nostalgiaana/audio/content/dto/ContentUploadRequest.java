package com.nostalgiaana.audio.content.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

import java.util.UUID;

@Data
public class ContentUploadRequest {

    @NotBlank(message = "Title is required")
    private String title;

    private String description;

    private UUID categoryId;

    private String speaker;

    // Lombok generates isPremium()/setIsPremium() for a primitive boolean field
    // already named "is...", which Jackson resolves to two different property
    // names ("premium" vs "isPremium") and silently drops incoming values.
    // Pinning the JSON key here sidesteps that mismatch.
    @JsonProperty("isPremium")
    private boolean isPremium = false;
}
