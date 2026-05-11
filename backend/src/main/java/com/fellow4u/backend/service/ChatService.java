package com.fellow4u.backend.service;

import com.fellow4u.backend.dto.ChatConversationResponse;
import com.fellow4u.backend.entity.ChatMessage;
import com.fellow4u.backend.entity.User;
import com.fellow4u.backend.repository.ChatMessageRepository;
import com.fellow4u.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ChatService {
    private final ChatMessageRepository chatMessageRepository;
    private final UserRepository userRepository;

    public List<ChatConversationResponse> getConversations(User currentUser) {
        List<ChatMessage> latestMessages = chatMessageRepository.findLatestMessagesForUser(currentUser);
        
        return latestMessages.stream().map(msg -> {
            User otherUser = msg.getSender().equals(currentUser) ? msg.getReceiver() : msg.getSender();
            return ChatConversationResponse.builder()
                    .otherUserId(otherUser.getId())
                    .otherUserName(otherUser.getFirstName() + " " + otherUser.getLastName())
                    .otherUserAvatar(otherUser.getAvatarUrl())
                    .lastMessage(msg.getContent())
                    .lastMessageTime(msg.getTimestamp())
                    .unreadCount(0) // Simplified for now
                    .build();
        }).collect(Collectors.toList());
    }

    public List<ChatMessage> getChatHistory(User currentUser, String otherUserId) {
        User otherUser = userRepository.findById(otherUserId)
                .orElseThrow(() -> new RuntimeException("User not found"));
        return chatMessageRepository.findChatHistory(currentUser, otherUser);
    }

    public ChatMessage sendMessage(User currentUser, String receiverId, String content) {
        User receiver = userRepository.findById(receiverId)
                .orElseThrow(() -> new RuntimeException("Receiver not found"));
        
        ChatMessage message = ChatMessage.builder()
                .sender(currentUser)
                .receiver(receiver)
                .content(content)
                .timestamp(LocalDateTime.now())
                .isRead(false)
                .build();
        
        return chatMessageRepository.save(message);
    }
}
