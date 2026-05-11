package com.fellow4u.backend.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "attractions")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Attraction {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    private String name;
    private String imageUrl;
    private String city;
}
