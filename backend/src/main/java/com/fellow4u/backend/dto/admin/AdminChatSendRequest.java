package com.fellow4u.backend.dto.admin;

import java.util.List;

public record AdminChatSendRequest(
        String receiverId,
        String type,
        String text,
        List<String> imageUrls,
        String audioUrl,
        Integer durationSeconds
) {
}
