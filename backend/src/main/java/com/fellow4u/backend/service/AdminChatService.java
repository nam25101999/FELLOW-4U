package com.fellow4u.backend.service;

import com.fellow4u.backend.dto.admin.AdminChatResponse;
import com.fellow4u.backend.dto.admin.AdminChatSendRequest;
import com.fellow4u.backend.entity.ChatMessage;
import com.fellow4u.backend.entity.User;
import com.fellow4u.backend.repository.ChatMessageRepository;
import com.fellow4u.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.Comparator;
import java.util.List;

@Service
@RequiredArgsConstructor
public class AdminChatService {

    private static final String IMAGE_PREFIX = "image::";
    private static final String AUDIO_PREFIX = "audio::";

    private final ChatMessageRepository chatMessageRepository;
    private final UserRepository userRepository;

    @Transactional(readOnly = true)
    public AdminChatResponse getChat(String userId) {
        User admin = currentAdmin();
        List<ChatMessage> allMessages = chatMessageRepository.findAll();
        List<AdminChatResponse.Conversation> conversations = buildConversations(admin, allMessages);

        User activeUser = resolveActiveUser(userId, conversations);
        List<ChatMessage> history = activeUser == null
                ? List.of()
                : chatMessageRepository.findChatHistory(admin, activeUser);

        AdminChatResponse.Conversation activeConversation = activeUser == null
                ? null
                : toConversation(activeUser, latestMessageBetween(admin, activeUser, allMessages), unreadCount(admin, activeUser, allMessages));

        return new AdminChatResponse(
                conversations,
                activeConversation,
                history.stream().map(message -> toMessage(admin, message)).toList()
        );
    }

    @Transactional
    public AdminChatResponse.Message send(AdminChatSendRequest request) {
        User admin = currentAdmin();
        User receiver = userRepository.findById(request.receiverId())
                .orElseThrow(() -> new IllegalArgumentException("Receiver not found"));

        ChatMessage message = ChatMessage.builder()
                .sender(admin)
                .receiver(receiver)
                .content(encodeContent(request))
                .timestamp(LocalDateTime.now())
                .isRead(false)
                .build();

        return toMessage(admin, chatMessageRepository.save(message));
    }

    private List<AdminChatResponse.Conversation> buildConversations(User admin, List<ChatMessage> messages) {
        return messages.stream()
                .filter(message -> sameUser(message.getSender(), admin) || sameUser(message.getReceiver(), admin))
                .map(message -> sameUser(message.getSender(), admin) ? message.getReceiver() : message.getSender())
                .filter(user -> user != null && !sameUser(user, admin))
                .distinct()
                .map(user -> toConversation(user, latestMessageBetween(admin, user, messages), unreadCount(admin, user, messages)))
                .sorted(Comparator.comparing(
                        AdminChatResponse.Conversation::lastMessageTime,
                        Comparator.nullsLast(Comparator.reverseOrder())
                ))
                .toList();
    }

    private User resolveActiveUser(String userId, List<AdminChatResponse.Conversation> conversations) {
        if (userId != null && !userId.isBlank()) {
            return userRepository.findById(userId).orElseThrow(() -> new IllegalArgumentException("User not found"));
        }

        if (!conversations.isEmpty()) {
            return userRepository.findById(conversations.get(0).userId()).orElse(null);
        }

        return userRepository.findByRole("TRAVELER").stream().findFirst().orElse(null);
    }

    private ChatMessage latestMessageBetween(User admin, User otherUser, List<ChatMessage> messages) {
        return messages.stream()
                .filter(message -> isBetween(message, admin, otherUser))
                .max(Comparator.comparing(ChatMessage::getTimestamp, Comparator.nullsLast(Comparator.naturalOrder())))
                .orElse(null);
    }

    private long unreadCount(User admin, User otherUser, List<ChatMessage> messages) {
        return messages.stream()
                .filter(message -> sameUser(message.getReceiver(), admin))
                .filter(message -> sameUser(message.getSender(), otherUser))
                .filter(message -> !message.isRead())
                .count();
    }

    private AdminChatResponse.Conversation toConversation(User user, ChatMessage latestMessage, long unreadCount) {
        return new AdminChatResponse.Conversation(
                user.getId(),
                fullName(user),
                user.getAvatarUrl(),
                latestMessage == null ? "" : displayContent(latestMessage.getContent()),
                latestMessage == null ? null : latestMessage.getTimestamp(),
                unreadCount
        );
    }

    private AdminChatResponse.Message toMessage(User admin, ChatMessage message) {
        String content = message.getContent() == null ? "" : message.getContent();
        String type = "text";
        String text = content;
        List<String> imageUrls = List.of();
        String audioUrl = null;
        Integer durationSeconds = null;

        if (content.startsWith(IMAGE_PREFIX)) {
            type = "image";
            imageUrls = Arrays.stream(content.substring(IMAGE_PREFIX.length()).split("\\|"))
                    .filter(value -> !value.isBlank())
                    .toList();
            text = "";
        } else if (content.startsWith(AUDIO_PREFIX)) {
            type = "audio";
            String[] parts = content.substring(AUDIO_PREFIX.length()).split("\\|");
            audioUrl = parts.length > 0 ? parts[0] : "";
            durationSeconds = parts.length > 1 ? parseInteger(parts[1]) : 0;
            text = "";
        }

        User sender = message.getSender();
        return new AdminChatResponse.Message(
                message.getId(),
                sender == null ? null : sender.getId(),
                sender == null ? "" : fullName(sender),
                sameUser(sender, admin),
                type,
                text,
                imageUrls,
                audioUrl,
                durationSeconds,
                message.getTimestamp()
        );
    }

    private String encodeContent(AdminChatSendRequest request) {
        String type = request.type() == null ? "text" : request.type();
        if ("image".equalsIgnoreCase(type)) {
            return IMAGE_PREFIX + String.join("|", request.imageUrls() == null ? List.of() : request.imageUrls());
        }
        if ("audio".equalsIgnoreCase(type)) {
            return AUDIO_PREFIX + (request.audioUrl() == null ? "" : request.audioUrl()) + "|" + (request.durationSeconds() == null ? 0 : request.durationSeconds());
        }
        return request.text() == null ? "" : request.text();
    }

    private String displayContent(String content) {
        if (content == null) {
            return "";
        }
        if (content.startsWith(IMAGE_PREFIX)) {
            return "Sent images";
        }
        if (content.startsWith(AUDIO_PREFIX)) {
            return "Sent a voice message";
        }
        return content;
    }

    private User currentAdmin() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(email).orElseThrow(() -> new IllegalStateException("Admin user not found"));
    }

    private boolean isBetween(ChatMessage message, User user1, User user2) {
        return (sameUser(message.getSender(), user1) && sameUser(message.getReceiver(), user2))
                || (sameUser(message.getSender(), user2) && sameUser(message.getReceiver(), user1));
    }

    private boolean sameUser(User left, User right) {
        return left != null && right != null && left.getId() != null && left.getId().equals(right.getId());
    }

    private String fullName(User user) {
        String name = ((user.getFirstName() == null ? "" : user.getFirstName()) + " "
                + (user.getLastName() == null ? "" : user.getLastName())).trim();
        return name.isBlank() ? user.getEmail() : name;
    }

    private Integer parseInteger(String value) {
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException exception) {
            return 0;
        }
    }
}
