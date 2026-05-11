package com.fellow4u.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "payment_methods")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PaymentMethod {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    private String name; // Ví dụ: MoMo, Visa **** 1234
    private String identifier; // Số điện thoại ví hoặc 4 số cuối thẻ
    private String provider; // MOMO, ZALOPAY, VISA, MASTERCARD, VNPAY
    private String type; // WALLET, CARD

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;
}
