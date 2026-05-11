package com.fellow4u.backend.repository;

import com.fellow4u.backend.entity.ChatMessage;
import com.fellow4u.backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface ChatMessageRepository extends JpaRepository<ChatMessage, String> {
    
    @Query("SELECT m FROM ChatMessage m WHERE " +
           "(m.sender = :user1 AND m.receiver = :user2) OR " +
           "(m.sender = :user2 AND m.receiver = :user1) " +
           "ORDER BY m.timestamp ASC")
    List<ChatMessage> findChatHistory(@Param("user1") User user1, @Param("user2") User user2);

    @Query("SELECT m FROM ChatMessage m WHERE m.id IN (" +
           "  SELECT MAX(m2.id) FROM ChatMessage m2 WHERE m2.sender = :user OR m2.receiver = :user " +
           "  GROUP BY (CASE WHEN m2.sender = :user THEN m2.receiver.id ELSE m2.sender.id END)" +
           ") ORDER BY m.timestamp DESC")
    List<ChatMessage> findLatestMessagesForUser(@Param("user") User user);
}
