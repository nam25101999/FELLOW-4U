package com.fellow4u.backend.repository;

import com.fellow4u.backend.entity.UserNotification;
import com.fellow4u.backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface NotificationRepository extends JpaRepository<UserNotification, String> {
    List<UserNotification> findByUserOrderByTimestampDesc(User user);
}
