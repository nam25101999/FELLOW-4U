package com.fellow4u.backend.repository;

import com.fellow4u.backend.entity.AdminSubscription;
import com.fellow4u.backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface AdminSubscriptionRepository extends JpaRepository<AdminSubscription, String> {
    Optional<AdminSubscription> findFirstByAdminUserOrderByStartedAtDesc(User adminUser);
}
