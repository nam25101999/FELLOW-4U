package com.fellow4u.backend.service;

import com.fellow4u.backend.dto.ExploreResponse;
import com.fellow4u.backend.entity.Tour;
import com.fellow4u.backend.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class ExploreService {
    private final TourRepository tourRepository;
    private final UserRepository userRepository;
    private final ExperienceRepository experienceRepository;
    private final TravelNewsRepository travelNewsRepository;

    public ExploreResponse getExploreData() {
        return ExploreResponse.builder()
                .topJourneys(tourRepository.findByCategory(Tour.TourCategory.TOP_JOURNEY))
                .bestGuides(userRepository.findAll().stream()
                        .filter(u -> "GUIDE".equals(u.getRole()))
                        .limit(4)
                        .toList())
                .topExperiences(experienceRepository.findAll())
                .featuredTours(tourRepository.findByCategory(Tour.TourCategory.FEATURED))
                .travelNews(travelNewsRepository.findAll().stream()
                        .sorted((a, b) -> b.getPublishedDate().compareTo(a.getPublishedDate()))
                        .limit(3)
                        .toList())
                .build();
    }

    public java.util.List<com.fellow4u.backend.entity.User> getAllGuides() {
        return userRepository.findAll().stream()
                .filter(u -> "GUIDE".equals(u.getRole()))
                .toList();
    }
}
