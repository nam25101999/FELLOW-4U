package com.fellow4u.backend.entity;

import jakarta.persistence.*;
import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Entity
@Table(name = "bookings")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Booking {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    private String tripTitle;
    private String location;
    private LocalDate date;
    private String timeSlot;
    private String guideName;
    private String guideAvatarUrl;
    private Integer travelers;
    private BigDecimal totalFee;
    private String status; // CURRENT, NEXT, PAST, WISH_LIST
    private String paymentStatus; // UNPAID, PAID_50, PAID_100
    
    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;

    @ManyToMany
    @JoinTable(
        name = "booking_attractions",
        joinColumns = @JoinColumn(name = "booking_id"),
        inverseJoinColumns = @JoinColumn(name = "attraction_id")
    )
    private List<Attraction> attractions;
}
