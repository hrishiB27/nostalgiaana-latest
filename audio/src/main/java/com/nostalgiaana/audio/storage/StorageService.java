package com.nostalgiaana.audio.storage;

import io.minio.*;
import io.minio.http.Method;
import jakarta.annotation.PostConstruct;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.InputStream;
import java.util.concurrent.TimeUnit;

@Service
@Slf4j
public class StorageService {

    private final MinioClient minioClient;
    private final MinioClient presignMinioClient;

    public StorageService(
            @Qualifier("minioClient") MinioClient minioClient,
            @Qualifier("presignMinioClient") MinioClient presignMinioClient) {
        this.minioClient = minioClient;
        this.presignMinioClient = presignMinioClient;
    }

    @Value("${minio.endpoint}")
    private String endpoint;

    @Value("${minio.bucket-audio}")
    private String audioBucket;

    @Value("${minio.bucket-covers}")
    private String coversBucket;

    @Value("${minio.bucket-video}")
    private String videoBucket;

    @Value("${minio.bucket-profile-pictures}")
    private String profilePicturesBucket;

    @PostConstruct
    public void initBuckets() {
        createBucketIfNotExists(audioBucket);
        createBucketIfNotExists(coversBucket);
        createBucketIfNotExists(videoBucket);
        createBucketIfNotExists(profilePicturesBucket);
    }

    private void createBucketIfNotExists(String bucketName) {
        try {
            boolean exists = minioClient.bucketExists(
                BucketExistsArgs.builder().bucket(bucketName).build()
            );
            if (!exists) {
                minioClient.makeBucket(
                    MakeBucketArgs.builder().bucket(bucketName).build()
                );
                log.info("Created bucket: {}", bucketName);
            }
        } catch (Exception e) {
            log.error("Failed to create/check bucket '{}' against endpoint '{}': {} - {}",
                    bucketName, endpoint, e.getClass().getSimpleName(), e.getMessage(), e);
            throw new RuntimeException("Failed to create bucket: " + bucketName, e);
        }
    }

    public void uploadFile(String bucketName, String objectName,
                           InputStream inputStream, long size, String contentType) {
        try {
            minioClient.putObject(
                PutObjectArgs.builder()
                    .bucket(bucketName)
                    .object(objectName)
                    .stream(inputStream, size, -1)
                    .contentType(contentType)
                    .build()
            );
        } catch (Exception e) {
            throw new RuntimeException("Failed to upload file: " + objectName, e);
        }
    }

    public void uploadMultipartFile(String bucketName, String objectName,
                                    MultipartFile file) {
        try (InputStream inputStream = file.getInputStream()) {
            minioClient.putObject(
                PutObjectArgs.builder()
                    .bucket(bucketName)
                    .object(objectName)
                    .stream(inputStream, file.getSize(), -1)
                    .contentType(file.getContentType())
                    .build()
            );
        } catch (Exception e) {
            throw new RuntimeException("Failed to upload file: " + objectName, e);
        }
    }

    public String getPresignedUrl(String bucketName, String objectName) {
        try {
            return presignMinioClient.getPresignedObjectUrl(
                GetPresignedObjectUrlArgs.builder()
                    .bucket(bucketName)
                    .object(objectName)
                    .method(Method.GET)
                    .expiry(1, TimeUnit.HOURS)
                    .build()
            );
        } catch (Exception e) {
            throw new RuntimeException("Failed to get presigned URL: " + objectName, e);
        }
    }

    public void deleteFile(String bucketName, String objectName) {
        try {
            minioClient.removeObject(
                RemoveObjectArgs.builder()
                    .bucket(bucketName)
                    .object(objectName)
                    .build()
            );
        } catch (Exception e) {
            throw new RuntimeException("Failed to delete file: " + objectName, e);
        }
    }

    public String getAudioBucket() {
        return audioBucket;
    }

    public String getCoversBucket() {
        return coversBucket;
    }

    public String getVideoBucket() {
        return videoBucket;
    }

    public String getProfilePicturesBucket() {
        return profilePicturesBucket;
    }
}