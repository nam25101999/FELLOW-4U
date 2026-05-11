package com.fellow4u.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;

@Entity
@Table(name = "admin_subscriptions")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class AdminSubscription {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    private String planName;
    private BigDecimal yearlyPrice;
    private LocalDate startedAt;
    private LocalDate validUntil;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "admin_user_id")
    private User adminUser;
}
