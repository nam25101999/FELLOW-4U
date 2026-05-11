package com.fellow4u.backend.dto;

import com.fellow4u.backend.entity.Experience;
import com.fellow4u.backend.entity.Tour;
import com.fellow4u.backend.entity.TravelNews;
import com.fellow4u.backend.entity.User;
import lombok.Builder;
import lombok.Data;

import java.util.List;

@Data
@Builder
public class ExploreResponse {
    private List<Tour> topJourneys;
    private List<User> bestGuides;
    private List<Experience> topExperiences;
    private List<Tour> featuredTours;
    private List<TravelNews> travelNews;
}
