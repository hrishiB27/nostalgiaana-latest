package com.nostalgiaana.audio.config;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

// Loud, non-fatal startup warning if security-critical config still equals
// the value shipped as a default in application.yaml. Those defaults exist
// so local dev works without every env var set — this doesn't fail startup
// (a legitimate first-time local setup with no env vars is expected to hit
// this and should still run), it's a visibility net for a real deployment
// that forgot to set the real value, not an enforcement gate.
@Component
@Slf4j
public class SecurityDefaultsCheckRunner implements ApplicationRunner {

    private static final String DEFAULT_JWT_SECRET = "nostalgiaana-super-secret-jwt-key-256-bits-long-enough";
    private static final String DEFAULT_ADMIN_PASSWORD = "AdminPassword123";

    @Value("${jwt.secret}")
    private String jwtSecret;

    @Value("${admin.bootstrap.password}")
    private String adminBootstrapPassword;

    @Value("${admin.bootstrap.enabled:false}")
    private boolean adminBootstrapEnabled;

    @Override
    public void run(ApplicationArguments args) {
        if (DEFAULT_JWT_SECRET.equals(jwtSecret)) {
            log.warn("SECURITY WARNING: JWT_SECRET is unset and falling back to the default value "
                    + "committed in application.yaml. Anyone with access to this repository can forge "
                    + "valid tokens for any user/role. Set JWT_SECRET before deploying to a real environment.");
        }
        if (adminBootstrapEnabled && DEFAULT_ADMIN_PASSWORD.equals(adminBootstrapPassword)) {
            log.warn("SECURITY WARNING: ADMIN_BOOTSTRAP_PASSWORD is unset and falling back to the "
                    + "default value committed in application.yaml, and admin.bootstrap.enabled=true resets "
                    + "both admin accounts to it on every restart. Set ADMIN_BOOTSTRAP_PASSWORD before "
                    + "deploying to a real environment.");
        }
    }
}
