package com.nostalgiaana.audio.content.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class StreamUrlResponse {

    private String url;
    private long expiresInSeconds;
}
