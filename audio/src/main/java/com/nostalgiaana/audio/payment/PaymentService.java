package com.nostalgiaana.audio.payment;

import com.nostalgiaana.audio.payment.dto.CreateOrderRequest;
import com.nostalgiaana.audio.payment.dto.CreateOrderResponse;
import com.nostalgiaana.audio.user.User;
import com.nostalgiaana.audio.user.UserRole;
import com.nostalgiaana.audio.user.UserService;
import com.razorpay.Order;
import com.razorpay.RazorpayClient;
import com.razorpay.RazorpayException;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.Optional;

@Service
@RequiredArgsConstructor
@Slf4j
public class PaymentService {

    private final PaymentRepository paymentRepository;
    private final UserService userService;
    private final RazorpayClient razorpayClient;

    @Value("${razorpay.key-id}")
    private String keyId;

    public CreateOrderResponse createOrder(User user, CreateOrderRequest request) {
        String currency = request.getCurrency() != null ? request.getCurrency() : "INR";

        JSONObject orderRequest = new JSONObject();
        // Razorpay expects the order amount in the smallest currency unit (e.g. paise for INR)
        orderRequest.put("amount", request.getAmount().multiply(BigDecimal.valueOf(100)).longValueExact());
        orderRequest.put("currency", currency);
        orderRequest.put("receipt", "receipt_" + System.currentTimeMillis());
        JSONObject notes = new JSONObject();
        notes.put("userId", user.getId().toString());
        orderRequest.put("notes", notes);

        Order order;
        try {
            order = razorpayClient.orders.create(orderRequest);
        } catch (RazorpayException e) {
            throw new RuntimeException("Failed to create payment order", e);
        }

        String razorpayOrderId = order.get("id");

        Payment payment = Payment.builder()
                .user(user)
                .amount(request.getAmount())
                .currency(currency)
                .razorpayOrderId(razorpayOrderId)
                .status("PENDING")
                .build();
        paymentRepository.save(payment);

        return CreateOrderResponse.builder()
                .razorpayOrderId(razorpayOrderId)
                .amount(request.getAmount())
                .currency(currency)
                .keyId(keyId)
                .build();
    }

    public void handleOrderPaid(JSONObject event) {
        JSONObject payload = event.getJSONObject("payload");
        String razorpayOrderId = payload.getJSONObject("order").getJSONObject("entity").getString("id");

        Optional<Payment> paymentOpt = paymentRepository.findByRazorpayOrderId(razorpayOrderId);
        if (paymentOpt.isEmpty()) {
            log.warn("Received order.paid webhook for unknown order {}", razorpayOrderId);
            return;
        }

        Payment payment = paymentOpt.get();
        if (payload.has("payment")) {
            payment.setRazorpayPaymentId(
                    payload.getJSONObject("payment").getJSONObject("entity").getString("id"));
        }
        payment.setStatus("SUCCESS");
        paymentRepository.save(payment);

        User user = payment.getUser();
        user.setRole(UserRole.PREMIUM);
        userService.save(user);
    }
}
