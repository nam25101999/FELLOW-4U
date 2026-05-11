package com.fellow4u.backend.repository;

import com.fellow4u.backend.entity.PasswordResetToken;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface PasswordResetTokenRepository extends JpaRepository<PasswordResetToken, String> {
    Optional<PasswordResetToken> findByTokenAndEmail(String token, String email);
    void deleteByEmail(String email);
}
