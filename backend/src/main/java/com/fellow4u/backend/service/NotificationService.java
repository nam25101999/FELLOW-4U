package com.fellow4u.backend.service;

import com.fellow4u.backend.entity.UserNotification;
import com.fellow4u.backend.entity.User;
import com.fellow4u.backend.repository.NotificationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
@RequiredArgsConstructor
public class NotificationService {
    private final NotificationRepository notificationRepository;

    public List<UserNotification> getNotifications(User user) {
        return notificationRepository.findByUserOrderByTimestampDesc(user);
    }
    
    @Transactional
    public void markAsRead(String id) {
        notificationRepository.findById(id).ifPresent(n -> {
            n.setRead(true);
            notificationRepository.save(n);
        });
    }
}
