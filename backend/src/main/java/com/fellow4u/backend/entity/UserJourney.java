package com.fellow4u.backend.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.util.List;

@Entity
@Table(name = "user_journeys")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserJourney {
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    private String title;
    private String location;
    private String date;
    private Integer likeCount;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id")
    private User user;

    @ElementCollection
    @CollectionTable(name = "journey_images", joinColumns = @JoinColumn(name = "journey_id"))
    @Column(name = "image_url")
    private List<String> imageUrls;
}
