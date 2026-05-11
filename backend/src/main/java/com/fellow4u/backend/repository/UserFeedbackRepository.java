package com.fellow4u.backend.repository;

import com.fellow4u.backend.entity.UserFeedback;
import org.springframework.data.jpa.repository.JpaRepository;

public interface UserFeedbackRepository extends JpaRepository<UserFeedback, String> {
}
