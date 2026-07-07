package com.nostalgiaana.audio.config;

import io.minio.MinioClient;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class MinioConfig {

    /**
     * Used for the app's own internal object operations (put/get/delete/
     * bucket management). In Docker this is the compose service name
     * ("http://minio:9000"), reachable only on the private backend
     * network; locally it's "http://localhost:9000" as before.
     */
    @Bean
    public MinioClient minioClient(
            @Value("${minio.endpoint}") String endpoint,
            @Value("${minio.access-key}") String accessKey,
            @Value("${minio.secret-key}") String secretKey) {
        return MinioClient.builder()
                .endpoint(endpoint)
                .credentials(accessKey, secretKey)
                .build();
    }

    /**
     * Used ONLY to generate presigned URLs handed to Flutter clients.
     * getPresignedObjectUrl() never opens a network connection — SigV4
     * presigning is a local HMAC computation — so this client's endpoint
     * just needs to be whatever externally-reachable host should end up
     * embedded (and correctly signed) in the URL. Points at the public
     * HTTPS domain in production; locally it's the same
     * "http://localhost:9000" as before.
     */
    @Bean
    public MinioClient presignMinioClient(
            @Value("${minio.public-endpoint}") String publicEndpoint,
            @Value("${minio.access-key}") String accessKey,
            @Value("${minio.secret-key}") String secretKey) {
        return MinioClient.builder()
                .endpoint(publicEndpoint)
                .credentials(accessKey, secretKey)
                .build();
    }
}
