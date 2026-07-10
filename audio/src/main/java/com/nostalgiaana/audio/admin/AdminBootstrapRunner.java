package com.nostalgiaana.audio.admin;

import com.nostalgiaana.audio.user.User;
import com.nostalgiaana.audio.user.UserRole;
import com.nostalgiaana.audio.user.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
@RequiredArgsConstructor
@Slf4j
public class AdminBootstrapRunner implements ApplicationRunner {

    private final UserService userService;
    private final PasswordEncoder passwordEncoder;

    @Value("${admin.bootstrap.enabled:false}")
    private boolean enabled;

    @Value("${admin.bootstrap.phone}")
    private String phone;

    @Value("${admin.bootstrap.country}")
    private String country;

    @Value("${admin.bootstrap.city}")
    private String city;

    @Value("${admin.bootstrap.password}")
    private String password;

    @Override
    public void run(ApplicationArguments args) {
        if (!enabled) {
            return;
        }

        User user = userService.findByPhone(phone).orElseGet(() -> User.builder()
                .phone(phone)
                .country(country)
                .city(city)
                .firstName("Admin")
                .lastName("User")
                .build());

        user.setRole(UserRole.ADMIN);
        user.setIsActive(true);
        user.setApproved(true);
        user.setPasswordHash(passwordEncoder.encode(password));

        userService.save(user);
        log.info("Admin bootstrap: ensured ADMIN account for {}", phone);
    }
}
