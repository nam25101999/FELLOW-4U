package com.fellow4u.backend.controller;

import com.fellow4u.backend.entity.User;
import com.fellow4u.backend.entity.UserJourney;
import com.fellow4u.backend.entity.UserPhoto;
import com.fellow4u.backend.entity.UserFeedback;
import com.fellow4u.backend.entity.PaymentMethod;
import com.fellow4u.backend.repository.PaymentMethodRepository;
import com.fellow4u.backend.repository.UserFeedbackRepository;
import com.fellow4u.backend.repository.UserJourneyRepository;
import com.fellow4u.backend.repository.UserPhotoRepository;
import com.fellow4u.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/profile")
@RequiredArgsConstructor
public class ProfileController {

    private final UserPhotoRepository photoRepository;
    private final UserJourneyRepository journeyRepository;
    private final UserRepository userRepository;
    private final PaymentMethodRepository paymentMethodRepository;
    private final UserFeedbackRepository feedbackRepository;
    private final PasswordEncoder passwordEncoder;

    @GetMapping("/me")
    public ResponseEntity<User> getMyProfile() {
        return ResponseEntity.ok(getCurrentUser());
    }

    @PutMapping("/me")
    public ResponseEntity<User> updateProfile(@RequestBody User updatedUser) {
        User user = getCurrentUser();
        user.setFirstName(updatedUser.getFirstName());
        user.setLastName(updatedUser.getLastName());
        if (updatedUser.getAvatarUrl() != null) {
            user.setAvatarUrl(updatedUser.getAvatarUrl());
        }
        return ResponseEntity.ok(userRepository.save(user));
    }

    @PostMapping("/change-password")
    public ResponseEntity<?> changePassword(@RequestBody Map<String, String> request) {
        User user = getCurrentUser();
        String currentPassword = request.get("currentPassword");
        String newPassword = request.get("newPassword");

        if (!passwordEncoder.matches(currentPassword, user.getPassword())) {
            return ResponseEntity.badRequest().body(Map.of("message", "Mật khẩu hiện tại không chính xác"));
        }

        user.setPassword(passwordEncoder.encode(newPassword));
        userRepository.save(user);
        return ResponseEntity.ok(Map.of("message", "Đổi mật khẩu thành công"));
    }

    @GetMapping("/photos")
    public ResponseEntity<List<UserPhoto>> getMyPhotos() {
        User user = getCurrentUser();
        return ResponseEntity.ok(photoRepository.findByUserId(user.getId()));
    }

    @PostMapping("/photos")
    public ResponseEntity<UserPhoto> addPhoto(@RequestBody Map<String, String> request) {
        User user = getCurrentUser();
        UserPhoto photo = UserPhoto.builder()
                .imageUrl(request.get("imageUrl"))
                .user(user)
                .createdAt(LocalDateTime.now())
                .build();
        return ResponseEntity.ok(photoRepository.save(photo));
    }

    @GetMapping("/journeys")
    public ResponseEntity<List<UserJourney>> getMyJourneys() {
        User user = getCurrentUser();
        return ResponseEntity.ok(journeyRepository.findByUserId(user.getId()));
    }

    @PostMapping("/journeys")
    public ResponseEntity<UserJourney> addJourney(@RequestBody UserJourney journey) {
        User user = getCurrentUser();
        journey.setUser(user);
        journey.setLikeCount(0);
        return ResponseEntity.ok(journeyRepository.save(journey));
    }

    @GetMapping("/cards")
    public ResponseEntity<List<PaymentMethod>> getMyCards() {
        User user = getCurrentUser();
        return ResponseEntity.ok(paymentMethodRepository.findByUser(user));
    }

    @PostMapping("/cards")
    public ResponseEntity<PaymentMethod> addCard(@RequestBody PaymentMethod method) {
        User user = getCurrentUser();
        method.setUser(user);
        return ResponseEntity.ok(paymentMethodRepository.save(method));
    }

    @DeleteMapping("/cards/{id}")
    public ResponseEntity<?> deleteCard(@PathVariable String id) {
        User user = getCurrentUser();
        PaymentMethod method = paymentMethodRepository.findById(id).orElseThrow();
        if (!method.getUser().getId().equals(user.getId())) {
            return ResponseEntity.status(403).body(Map.of("message", "Không có quyền xóa phương thức này"));
        }
        paymentMethodRepository.delete(method);
        return ResponseEntity.ok(Map.of("message", "Xóa phương thức thành công"));
    }

    @PostMapping("/feedback")
    public ResponseEntity<?> submitFeedback(@RequestBody Map<String, String> request) {
        User user = getCurrentUser();
        UserFeedback feedback = UserFeedback.builder()
                .content(request.get("content"))
                .user(user)
                .build();
        feedbackRepository.save(feedback);
        return ResponseEntity.ok(Map.of("message", "Gửi phản hồi thành công"));
    }

    private User getCurrentUser() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(email).orElseThrow();
    }
}
