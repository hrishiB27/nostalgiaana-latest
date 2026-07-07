package com.nostalgiaana.audio.content;

import com.nostalgiaana.audio.category.Category;
import com.nostalgiaana.audio.category.CategoryRepository;
import com.nostalgiaana.audio.content.dto.ContentDetailResponse;
import com.nostalgiaana.audio.content.dto.ContentResponse;
import com.nostalgiaana.audio.content.dto.ContentUploadRequest;
import com.nostalgiaana.audio.content.dto.StreamUrlResponse;
import com.nostalgiaana.audio.storage.StorageService;
import com.nostalgiaana.audio.user.User;
import com.nostalgiaana.audio.user.UserRole;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.UUID;
import java.util.concurrent.TimeUnit;

@Service
@RequiredArgsConstructor
public class ContentService {

    private static final long STREAM_URL_EXPIRY_SECONDS = TimeUnit.HOURS.toSeconds(1);

    private final ContentRepository contentRepository;
    private final CategoryRepository categoryRepository;
    private final StorageService storageService;

    public ContentResponse upload(ContentType contentType, ContentUploadRequest request,
                                   MultipartFile mediaFile, MultipartFile coverFile, User uploadedBy) {

        validateMediaContentType(contentType, mediaFile);
        validateIsImage(coverFile, "Thumbnail");

        Category category = null;
        if (request.getCategoryId() != null) {
            category = categoryRepository.findById(request.getCategoryId())
                    .orElseThrow(() -> new RuntimeException("Category not found"));
        }

        Content content = Content.builder()
                .title(request.getTitle())
                .description(request.getDescription())
                .category(category)
                .speaker(request.getSpeaker())
                .isPremium(request.isPremium())
                .contentType(contentType)
                .uploadedBy(uploadedBy)
                .build();

        content = contentRepository.save(content);

        String mediaKey = content.getId() + extensionOf(mediaFile.getOriginalFilename());
        if (contentType == ContentType.SHOW) {
            storageService.uploadMultipartFile(storageService.getVideoBucket(), mediaKey, mediaFile);
            content.setRawVideoPath(mediaKey);
        } else {
            storageService.uploadMultipartFile(storageService.getAudioBucket(), mediaKey, mediaFile);
            content.setRawAudioPath(mediaKey);
        }

        if (coverFile != null && !coverFile.isEmpty()) {
            String coverKey = content.getId() + extensionOf(coverFile.getOriginalFilename());
            storageService.uploadMultipartFile(storageService.getCoversBucket(), coverKey, coverFile);
            content.setCoverPath(coverKey);
        }

        content = contentRepository.save(content);

        return toResponse(content);
    }

    public StreamUrlResponse getStreamUrl(UUID contentId, User requester) {
        Content content = contentRepository.findById(contentId)
                .orElseThrow(() -> new RuntimeException("Content not found"));

        if (Boolean.TRUE.equals(content.getIsPremium()) && requester.getRole() == UserRole.LISTENER) {
            throw new RuntimeException("Premium content requires subscription");
        }

        String bucket;
        String objectKey;
        if (content.getContentType() == ContentType.SHOW) {
            bucket = storageService.getVideoBucket();
            objectKey = content.getRawVideoPath();
        } else {
            bucket = storageService.getAudioBucket();
            objectKey = content.getRawAudioPath();
        }

        String url = storageService.getPresignedUrl(bucket, objectKey);

        return StreamUrlResponse.builder()
                .url(url)
                .expiresInSeconds(STREAM_URL_EXPIRY_SECONDS)
                .build();
    }

    public List<ContentResponse> listByType(ContentType contentType, UUID categoryId) {
        List<Content> content = categoryId == null
                ? contentRepository.findByContentTypeOrderByUploadDateDesc(contentType)
                : contentRepository.findByContentTypeAndCategoryIdOrderByUploadDateDesc(contentType, categoryId);
        return content.stream()
                .map(this::toResponse)
                .toList();
    }

    public List<ContentDetailResponse> listDetailedByType(ContentType contentType) {
        return contentRepository.findByContentTypeOrderByUploadDateDesc(contentType).stream()
                .map(this::toDetailResponse)
                .toList();
    }

    public ContentDetailResponse updateMetadata(UUID id, ContentType expectedType,
                                                 ContentUploadRequest request, MultipartFile newThumbnail) {
        Content content = findByIdAndType(id, expectedType);
        validateIsImage(newThumbnail, "Thumbnail");

        Category category = null;
        if (request.getCategoryId() != null) {
            category = categoryRepository.findById(request.getCategoryId())
                    .orElseThrow(() -> new RuntimeException("Category not found"));
        }

        content.setTitle(request.getTitle());
        content.setDescription(request.getDescription());
        content.setCategory(category);
        content.setSpeaker(request.getSpeaker());
        content.setIsPremium(request.isPremium());

        if (newThumbnail != null && !newThumbnail.isEmpty()) {
            if (content.getCoverPath() != null) {
                storageService.deleteFile(storageService.getCoversBucket(), content.getCoverPath());
            }
            String coverKey = content.getId() + extensionOf(newThumbnail.getOriginalFilename());
            storageService.uploadMultipartFile(storageService.getCoversBucket(), coverKey, newThumbnail);
            content.setCoverPath(coverKey);
        }

        content = contentRepository.save(content);

        return toDetailResponse(content);
    }

    public void delete(UUID id, ContentType expectedType) {
        Content content = findByIdAndType(id, expectedType);

        if (content.getRawAudioPath() != null) {
            storageService.deleteFile(storageService.getAudioBucket(), content.getRawAudioPath());
        }
        if (content.getRawVideoPath() != null) {
            storageService.deleteFile(storageService.getVideoBucket(), content.getRawVideoPath());
        }
        if (content.getCoverPath() != null) {
            storageService.deleteFile(storageService.getCoversBucket(), content.getCoverPath());
        }

        contentRepository.delete(content);
    }

    private Content findByIdAndType(UUID id, ContentType expectedType) {
        Content content = contentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Content not found"));
        if (content.getContentType() != expectedType) {
            throw new RuntimeException("Content not found");
        }
        return content;
    }

    private void validateMediaContentType(ContentType contentType, MultipartFile mediaFile) {
        String declaredType = mediaFile.getContentType();
        String expectedPrefix = contentType == ContentType.SHOW ? "video/" : "audio/";
        if (declaredType == null || !declaredType.startsWith(expectedPrefix)) {
            throw new RuntimeException(
                    (contentType == ContentType.SHOW ? "Show" : "Audio") + " upload requires a "
                            + expectedPrefix + "* file, got: " + declaredType);
        }
    }

    private void validateIsImage(MultipartFile file, String label) {
        if (file == null || file.isEmpty()) {
            return;
        }
        String declaredType = file.getContentType();
        if (declaredType == null || !declaredType.startsWith("image/")) {
            throw new RuntimeException(label + " must be an image file, got: " + declaredType);
        }
    }

    private String extensionOf(String originalFilename) {
        if (originalFilename == null) {
            return "";
        }
        int dotIndex = originalFilename.lastIndexOf('.');
        return dotIndex >= 0 ? originalFilename.substring(dotIndex) : "";
    }

    private ContentResponse toResponse(Content content) {
        return ContentResponse.builder()
                .id(content.getId())
                .title(content.getTitle())
                .description(content.getDescription())
                .contentType(content.getContentType())
                .categoryId(content.getCategory() != null ? content.getCategory().getId() : null)
                .categoryName(content.getCategory() != null ? content.getCategory().getName() : null)
                .speaker(content.getSpeaker())
                .durationSeconds(content.getDurationSeconds())
                .isPremium(content.getIsPremium())
                .playCount(content.getPlayCount())
                .uploadDate(content.getUploadDate())
                .coverUrl(presignedCoverUrl(content))
                .build();
    }

    private ContentDetailResponse toDetailResponse(Content content) {
        User uploadedBy = content.getUploadedBy();
        return ContentDetailResponse.builder()
                .id(content.getId())
                .title(content.getTitle())
                .description(content.getDescription())
                .contentType(content.getContentType())
                .categoryId(content.getCategory() != null ? content.getCategory().getId() : null)
                .categoryName(content.getCategory() != null ? content.getCategory().getName() : null)
                .speaker(content.getSpeaker())
                .durationSeconds(content.getDurationSeconds())
                .isPremium(content.getIsPremium())
                .playCount(content.getPlayCount())
                .uploadDate(content.getUploadDate())
                .rawAudioPath(content.getRawAudioPath())
                .rawVideoPath(content.getRawVideoPath())
                .coverPath(content.getCoverPath())
                .coverUrl(presignedCoverUrl(content))
                .hlsManifestPath(content.getHlsManifestPath())
                .uploadedByUserId(uploadedBy != null ? uploadedBy.getId() : null)
                .uploadedByName(uploadedBy != null ? (uploadedBy.getFirstName() + " " + uploadedBy.getLastName()) : null)
                .build();
    }

    private String presignedCoverUrl(Content content) {
        if (content.getCoverPath() == null) {
            return null;
        }
        return storageService.getPresignedUrl(storageService.getCoversBucket(), content.getCoverPath());
    }
}
