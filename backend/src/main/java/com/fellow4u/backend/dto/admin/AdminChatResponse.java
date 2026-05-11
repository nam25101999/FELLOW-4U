package com.fellow4u.backend.dto.admin;

import java.time.LocalDateTime;
import java.util.List;

public record AdminChatResponse(
        List<Conversation> conversations,
        Conversation activeConversation,
        List<Message> messages
) {
    public record Conversation(
            String userId,
            String name,
            String avatarUrl,
            String lastMessage,
            LocalDateTime lastMessageTime,
            long unreadCount
    ) {
    }

    public record Message(
            String id,
            String senderId,
            String senderName,
            boolean mine,
            String type,
            String text,
            List<String> imageUrls,
            String audioUrl,
            Integer durationSeconds,
            LocalDateTime timestamp
    ) {
    }
}
