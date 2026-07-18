package com.nostalgiaana.audio.auth;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

/**
 * Replaces Spring Security's default bodyless rejection (which the frontend
 * can't extract any message from) with the same {@code {error, status,
 * timestamp}} JSON shape {@code GlobalExceptionHandler} already uses, so
 * {@code messageFor()} on the frontend picks it up unmodified. {@link
 * JwtAuthFilter} stashes a specific reason (suspended/unapproved) on the
 * request when it recognizes the user but rejects them; anything else
 * (missing/invalid/expired token) falls back to a generic message.
 *
 * <p>Owns its own {@link ObjectMapper} instead of having Spring inject one —
 * this project's {@code spring-boot-starter-webmvc} dependency doesn't
 * transitively expose an autoconfigured {@code ObjectMapper} bean the way
 * {@code spring-boot-starter-web} does, and this class runs at the servlet
 * filter level anyway, outside normal MVC dispatch.
 */
@Component
public class JsonAuthenticationEntryPoint implements AuthenticationEntryPoint {

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public void commence(HttpServletRequest request, HttpServletResponse response,
                          AuthenticationException authException) throws IOException {
        String reason = (String) request.getAttribute("authRejectionReason");
        int status = reason != null ? HttpServletResponse.SC_FORBIDDEN : HttpServletResponse.SC_UNAUTHORIZED;

        response.setStatus(status);
        response.setContentType("application/json");

        Map<String, Object> body = new HashMap<>();
        body.put("error", reason != null ? reason : "Authentication required");
        body.put("status", status);
        body.put("timestamp", LocalDateTime.now().toString());
        objectMapper.writeValue(response.getWriter(), body);
    }
}
