package com.nostalgiaana.audio.payment;

import com.nostalgiaana.audio.payment.dto.CreateOrderRequest;
import com.nostalgiaana.audio.payment.dto.CreateOrderResponse;
import com.nostalgiaana.audio.user.User;
import com.razorpay.RazorpayException;
import com.razorpay.Utils;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.nio.charset.StandardCharsets;

@RestController
@RequestMapping("/api/payments")
@RequiredArgsConstructor
public class PaymentController {

    private final PaymentService paymentService;

    @Value("${razorpay.webhook-secret}")
    private String webhookSecret;

    @PostMapping("/create-order")
    public ResponseEntity<CreateOrderResponse> createOrder(
            @Valid @RequestBody CreateOrderRequest request,
            @AuthenticationPrincipal User currentUser) {
        return ResponseEntity.ok(paymentService.createOrder(currentUser, request));
    }

    @PostMapping("/webhook")
    public ResponseEntity<Void> webhook(
            HttpServletRequest httpRequest,
            @RequestHeader("X-Razorpay-Signature") String signature) throws IOException {

        String payload = new String(httpRequest.getInputStream().readAllBytes(), StandardCharsets.UTF_8);

        boolean valid;
        try {
            valid = Utils.verifyWebhookSignature(payload, signature, webhookSecret);
        } catch (RazorpayException e) {
            return ResponseEntity.badRequest().build();
        }

        if (!valid) {
            return ResponseEntity.badRequest().build();
        }

        JSONObject event = new JSONObject(payload);
        if ("order.paid".equals(event.optString("event"))) {
            paymentService.handleOrderPaid(event);
        }

        return ResponseEntity.ok().build();
    }
}
