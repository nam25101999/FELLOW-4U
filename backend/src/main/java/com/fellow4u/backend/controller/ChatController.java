package com.fellow4u.backend.controller;

import com.fellow4u.backend.dto.ChatConversationResponse;
import com.fellow4u.backend.entity.ChatMessage;
import com.fellow4u.backend.entity.User;
import com.fellow4u.backend.service.ChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/chat")
@RequiredArgsConstructor
public class ChatController {
    private final ChatService chatService;

    @GetMapping("/conversations")
    public ResponseEntity<List<ChatConversationResponse>> getConversations(@AuthenticationPrincipal User currentUser) {
        return ResponseEntity.ok(chatService.getConversations(currentUser));
    }

    @GetMapping("/history/{otherUserId}")
    public ResponseEntity<List<ChatMessage>> getChatHistory(
            @AuthenticationPrincipal User currentUser,
            @PathVariable String otherUserId) {
        return ResponseEntity.ok(chatService.getChatHistory(currentUser, otherUserId));
    }

    @PostMapping("/send")
    public ResponseEntity<ChatMessage> sendMessage(
            @AuthenticationPrincipal User currentUser,
            @RequestParam String receiverId,
            @RequestParam String content) {
        return ResponseEntity.ok(chatService.sendMessage(currentUser, receiverId, content));
    }
}
