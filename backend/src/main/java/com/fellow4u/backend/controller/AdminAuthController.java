package com.fellow4u.backend.controller;

import com.fellow4u.backend.dto.AuthResponse;
import com.fellow4u.backend.dto.LoginRequest;
import com.fellow4u.backend.repository.UserRepository;
import com.fellow4u.backend.security.JwtService;
import com.fellow4u.backend.service.AuthService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.Map;

@RestController
@RequestMapping("/api/admin/auth")
@RequiredArgsConstructor
public class AdminAuthController {

    private final UserRepository userRepository;
    private final AuthenticationManager authenticationManager;
    private final JwtService jwtService;
    private final AuthService authService;

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(request.getEmail(), request.getPassword())
        );

        var user = userRepository.findByEmail(request.getEmail()).orElseThrow();
        ensureAdmin(user.getRole());

        return ResponseEntity.ok(AuthResponse.builder()
                .token(jwtService.generateToken(user))
                .email(user.getEmail())
                .role(user.getRole())
                .build());
    }

    @PostMapping("/forgot-password")
    public ResponseEntity<?> forgotPassword(@RequestBody Map<String, String> request) {
        String email = request.get("email");
        ensureAdminEmail(email);
        authService.forgotPassword(email);
        return ResponseEntity.ok(Map.of("message", "Reset instructions were sent to the admin email"));
    }

    @PostMapping("/verify-otp")
    public ResponseEntity<?> verifyOtp(@RequestBody Map<String, String> request) {
        String email = request.get("email");
        ensureAdminEmail(email);
        authService.verifyOtp(email, request.get("otp"));
        return ResponseEntity.ok(Map.of("message", "OTP is valid"));
    }

    @PostMapping("/reset-password")
    public ResponseEntity<?> resetPassword(@RequestBody Map<String, String> request) {
        String email = request.get("email");
        ensureAdminEmail(email);
        authService.resetPassword(email, request.get("otp"), request.get("newPassword"));
        return ResponseEntity.ok(Map.of("message", "Admin password has been reset"));
    }

    private void ensureAdminEmail(String email) {
        var user = userRepository.findByEmail(email)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Admin email not found"));
        ensureAdmin(user.getRole());
    }

    private void ensureAdmin(String role) {
        if (!"ADMIN".equals(role)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only admin accounts can use this endpoint");
        }
    }
}
