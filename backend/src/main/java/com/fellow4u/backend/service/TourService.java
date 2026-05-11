package com.fellow4u.backend.service;

import com.fellow4u.backend.entity.Tour;
import com.fellow4u.backend.entity.User;
import com.fellow4u.backend.repository.TourRepository;
import com.fellow4u.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Set;

@Service
@RequiredArgsConstructor
public class TourService {
    private final TourRepository tourRepository;
    private final UserRepository userRepository;

    @Transactional
    public boolean toggleLike(String tourId) {
        User user = getCurrentUser();
        Tour tour = tourRepository.findById(tourId).orElseThrow(() -> new RuntimeException("Tour not found"));
        
        if (user.getLikedTours().contains(tour)) {
            user.getLikedTours().remove(tour);
            userRepository.save(user);
            return false;
        } else {
            user.getLikedTours().add(tour);
            userRepository.save(user);
            return true;
        }
    }

    @Transactional
    public boolean toggleBookmark(String tourId) {
        User user = getCurrentUser();
        Tour tour = tourRepository.findById(tourId).orElseThrow(() -> new RuntimeException("Tour not found"));
        
        if (user.getBookmarkedTours().contains(tour)) {
            user.getBookmarkedTours().remove(tour);
            userRepository.save(user);
            return false;
        } else {
            user.getBookmarkedTours().add(tour);
            userRepository.save(user);
            return true;
        }
    }

    public boolean isLiked(String tourId) {
        User user = getCurrentUser();
        Tour tour = tourRepository.findById(tourId).orElseThrow(() -> new RuntimeException("Tour not found"));
        return user.getLikedTours().contains(tour);
    }

    public boolean isBookmarked(String tourId) {
        User user = getCurrentUser();
        Tour tour = tourRepository.findById(tourId).orElseThrow(() -> new RuntimeException("Tour not found"));
        return user.getBookmarkedTours().contains(tour);
    }

    public Set<Tour> getLikedTours() {
        return getCurrentUser().getLikedTours();
    }

    public Set<Tour> getBookmarkedTours() {
        return getCurrentUser().getBookmarkedTours();
    }

    private User getCurrentUser() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(email).orElseThrow(() -> new RuntimeException("User not found"));
    }
}
