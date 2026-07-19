package com.nostalgiaana.audio.sms;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.util.Base64;
import java.util.Map;

/**
 * Sends OTP SMS via Twilio's REST API using the JDK's own HTTP client —
 * deliberately not the Twilio SDK or Spring's RestTemplate, to avoid both a
 * heavier dependency and this project's already-once-bitten assumption that
 * spring-boot-starter-webmvc auto-configures every bean spring-boot-starter-web
 * would (see JsonAuthenticationEntryPoint's ObjectMapper). Never throws — a
 * failed send (including with placeholder credentials) is logged, not
 * propagated, so login/OTP generation still succeeds without real Twilio
 * credentials configured, mirroring RazorpayConfig's tolerant posture.
 */
@Service
@Slf4j
public class SmsService {

    // Mirrors frontend/lib/core/data/countries.dart's curated country list —
    // keep both in sync if either changes.
    private static final Map<String, String> DIAL_CODES = Map.ofEntries(
            Map.entry("India", "+91"),
            Map.entry("United States", "+1"),
            Map.entry("United Kingdom", "+44"),
            Map.entry("Canada", "+1"),
            Map.entry("Australia", "+61"),
            Map.entry("United Arab Emirates", "+971"),
            Map.entry("Singapore", "+65"),
            Map.entry("New Zealand", "+64"),
            Map.entry("South Africa", "+27"),
            Map.entry("Germany", "+49"),
            Map.entry("France", "+33"),
            Map.entry("Qatar", "+974"),
            Map.entry("Saudi Arabia", "+966"),
            Map.entry("Kuwait", "+965"),
            Map.entry("Mauritius", "+230"),
            Map.entry("Malaysia", "+60")
    );

    private final HttpClient httpClient = HttpClient.newHttpClient();

    @Value("${twilio.account-sid}")
    private String accountSid;

    @Value("${twilio.auth-token}")
    private String authToken;

    @Value("${twilio.from-number}")
    private String fromNumber;

    /** Falls back to India's +91 for any country not in the curated list. */
    public static String toE164(String country, String localNumber) {
        return DIAL_CODES.getOrDefault(country, "+91") + localNumber;
    }

    public void sendOtp(String toE164Number, String otp) {
        String body = "To=" + encode(toE164Number)
                + "&From=" + encode(fromNumber)
                + "&Body=" + encode("Your Nostalgiaana verification code is " + otp);

        String credentials = Base64.getEncoder()
                .encodeToString((accountSid + ":" + authToken).getBytes(StandardCharsets.UTF_8));

        HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create("https://api.twilio.com/2010-04-01/Accounts/" + accountSid + "/Messages.json"))
                .header("Authorization", "Basic " + credentials)
                .header("Content-Type", "application/x-www-form-urlencoded")
                .POST(HttpRequest.BodyPublishers.ofString(body))
                .build();

        try {
            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
            if (response.statusCode() >= 300) {
                log.error("Twilio SMS send failed ({}): {}", response.statusCode(), response.body());
            }
        } catch (IOException e) {
            log.error("Twilio SMS send failed", e);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
            log.error("Twilio SMS send interrupted", e);
        }
    }

    private static String encode(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }
}
