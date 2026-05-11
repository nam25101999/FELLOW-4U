package com.fellow4u.backend.repository;

import com.fellow4u.backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;
import java.util.List;

public interface UserRepository extends JpaRepository<User, String> {
    Optional<User> findByEmail(String email);
    boolean existsByEmail(String email);
    List<User> findByRole(String role);
    List<User> findByRoleAndLocationContainingIgnoreCase(String role, String location);
    long countByRole(String role);
}
