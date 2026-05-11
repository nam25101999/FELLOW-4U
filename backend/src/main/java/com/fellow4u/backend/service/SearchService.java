package com.fellow4u.backend.service;

import com.fellow4u.backend.dto.ExploreResponse;
import com.fellow4u.backend.entity.Tour;
import com.fellow4u.backend.repository.ExperienceRepository;
import com.fellow4u.backend.repository.TourRepository;
import com.fellow4u.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.Collections;

@Service
@RequiredArgsConstructor
public class SearchService {
    private final UserRepository userRepository;
    private final TourRepository tourRepository;
    private final ExperienceRepository experienceRepository;

    public ExploreResponse search(String query) {
        if (query == null || query.trim().isEmpty()) {
            return ExploreResponse.builder()
                    .bestGuides(Collections.emptyList())
                    .featuredTours(Collections.emptyList())
                    .topExperiences(Collections.emptyList())
                    .topJourneys(Collections.emptyList())
                    .travelNews(Collections.emptyList())
                    .build();
        }

        String q = query.trim();

        return ExploreResponse.builder()
                .bestGuides(userRepository.findByRoleAndLocationContainingIgnoreCase("GUIDE", q))
                .featuredTours(tourRepository.findByTitleContainingIgnoreCase(q))
                .topExperiences(experienceRepository.findByTitleContainingIgnoreCase(q))
                .topJourneys(Collections.emptyList()) // We can filter this too if needed
                .travelNews(Collections.emptyList())
                .build();
    }
}
