package com.nostalgiaana.audio.payment;

import com.nostalgiaana.audio.user.User;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.UUID;

@Entity
@Table(name = "payments")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Payment {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;

    @Column(nullable = false)
    private BigDecimal amount;

    @Builder.Default
    private String currency = "INR";

    private String razorpayOrderId;

    private String razorpayPaymentId;

    @Builder.Default
    private String status = "PENDING";

    @Builder.Default
    private LocalDateTime createdAt = LocalDateTime.now();
}
