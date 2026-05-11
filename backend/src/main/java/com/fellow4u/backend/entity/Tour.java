package com.fellow4u.backend.entity;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.EqualsAndHashCode;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;

@Entity
@Table(name = "tours")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@EqualsAndHashCode(onlyExplicitlyIncluded = true)
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class Tour {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    @EqualsAndHashCode.Include
    private String id;

    private String title;
    private String description;
    private String imageUrl;
    private BigDecimal price;
    private String location;
    private String duration; // e.g. "3 days"
    private LocalDate startDate;
    private Double rating;
    private Integer reviewCount;
    
    @Enumerated(EnumType.STRING)
    private TourCategory category;

    public enum TourCategory {
        TOP_JOURNEY, FEATURED, REGULAR
    }
}
