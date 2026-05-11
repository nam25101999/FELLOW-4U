package com.fellow4u.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.time.LocalDate;

@Entity
@Table(name = "travel_news")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class TravelNews {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    private String title;
    private String imageUrl;
    private LocalDate publishedDate;
}
