package com.fellow4u.backend.service;

import com.fellow4u.backend.dto.AuthResponse;
import com.fellow4u.backend.dto.LoginRequest;
import com.fellow4u.backend.entity.PasswordResetToken;
import com.fellow4u.backend.repository.PasswordResetTokenRepository;
import com.fellow4u.backend.repository.UserRepository;
import com.fellow4u.backend.security.JwtService;
import lombok.RequiredArgsConstructor;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Random;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordResetTokenRepository tokenRepository;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;
    private final PasswordEncoder passwordEncoder;
    private final JavaMailSender mailSender;

    public com.fellow4u.backend.dto.AuthResponse login(com.fellow4u.backend.dto.LoginRequest request) {
        authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getEmail(),
                        request.getPassword()
                )
        );
        var user = userRepository.findByEmail(request.getEmail())
                .orElseThrow();
        var jwtToken = jwtService.generateToken(user);
        return AuthResponse.builder()
                .token(jwtToken)
                .email(user.getEmail())
                .role(user.getRole())
                .build();
    }

    @Transactional
    public void forgotPassword(String email) {
        if (!userRepository.existsByEmail(email)) {
            throw new RuntimeException("Email không tồn tại");
        }

        tokenRepository.deleteByEmail(email);

        String otp = String.format("%06d", new Random().nextInt(999999));
        PasswordResetToken token = PasswordResetToken.builder()
                .token(otp)
                .email(email)
                .expiryDate(LocalDateTime.now().plusMinutes(5))
                .build();

        tokenRepository.save(token);

        sendEmail(email, "Mã OTP đặt lại mật khẩu - Fellow4U", 
            "Mã OTP của bạn là: " + otp + ". Mã này có hiệu lực trong 5 phút.");
    }

    private void sendEmail(String to, String subject, String body) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setFrom("nam102154@donga.edu.vn");
        message.setTo(to);
        message.setSubject(subject);
        message.setText(body);
        mailSender.send(message);
    }

    public void verifyOtp(String email, String otp) {
        var token = tokenRepository.findByTokenAndEmail(otp, email)
                .orElseThrow(() -> new RuntimeException("Mã OTP không đúng"));

        if (token.isExpired()) {
            throw new RuntimeException("Mã OTP đã hết hạn");
        }
    }

    @Transactional
    public void resetPassword(String email, String otp, String newPassword) {
        verifyOtp(email, otp);

        var user = userRepository.findByEmail(email)
                .orElseThrow(() -> new RuntimeException("Người dùng không tồn tại"));

        user.setPassword(passwordEncoder.encode(newPassword));
        userRepository.save(user);

        tokenRepository.deleteByEmail(email);
    }
}
