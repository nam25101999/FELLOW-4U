package com.fellow4u.backend.entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDateTime;

@Entity
@Table(name = "notifications")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class UserNotification {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    @JsonIgnoreProperties({"hibernateLazyInitializer", "handler", "password", "role"})
    private User user;

    private String title;
    
    @Column(columnDefinition = "TEXT")
    private String message;
    
    private String avatarUrl;
    private String type; // TRIP_ACCEPTED, TRIP_FINISHED, OFFER_RECEIVED
    private LocalDateTime timestamp;
    
    @Column(name = "is_read")
    @Builder.Default
    @JsonProperty("isRead")
    private boolean read = false;
    
    private String actionType; // LEAVE_REVIEW, VIEW_DETAILS
}
