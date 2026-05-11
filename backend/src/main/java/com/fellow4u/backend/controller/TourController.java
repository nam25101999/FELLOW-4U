package com.fellow4u.backend.controller;

import com.fellow4u.backend.service.TourService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.Set;
import com.fellow4u.backend.entity.Tour;

@RestController
@RequestMapping("/api/tours")
@RequiredArgsConstructor
public class TourController {
    private final TourService tourService;

    @PostMapping("/{id}/like")
    public ResponseEntity<?> toggleLike(@PathVariable String id) {
        boolean liked = tourService.toggleLike(id);
        return ResponseEntity.ok(Map.of("liked", liked));
    }

    @PostMapping("/{id}/bookmark")
    public ResponseEntity<?> toggleBookmark(@PathVariable String id) {
        boolean bookmarked = tourService.toggleBookmark(id);
        return ResponseEntity.ok(Map.of("bookmarked", bookmarked));
    }

    @GetMapping("/{id}/status")
    public ResponseEntity<?> getStatus(@PathVariable String id) {
        return ResponseEntity.ok(Map.of(
            "liked", tourService.isLiked(id),
            "bookmarked", tourService.isBookmarked(id)
        ));
    }

    @GetMapping("/liked")
    public ResponseEntity<Set<Tour>> getLikedTours() {
        return ResponseEntity.ok(tourService.getLikedTours());
    }

    @GetMapping("/bookmarked")
    public ResponseEntity<Set<Tour>> getBookmarkedTours() {
        return ResponseEntity.ok(tourService.getBookmarkedTours());
    }
}
