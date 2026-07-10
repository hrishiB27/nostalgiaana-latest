package com.nostalgiaana.audio.user;
import lombok.*;
import jakarta.persistence.*;
import java.util.UUID;
import java.time.LocalDateTime;
@Entity
@Table(name = "users")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class User {
    @Id 
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    @Column(unique = true)
    private String phone;

    private String passwordHash;

    private String firstName;

    private String lastName;

    private String country;

    private String city;

    private String profilePicPath;

    @Enumerated(EnumType.STRING)
@Column(nullable = false)
@Builder.Default
private UserRole role = UserRole.LISTENER;

    @Column(unique = true)
    private String googleId;

    @Builder.Default
    private Boolean isActive = true;

    @Builder.Default
    private Boolean approved = false;

    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();

    @Builder.Default
    private LocalDateTime updatedAt = LocalDateTime.now();
}
