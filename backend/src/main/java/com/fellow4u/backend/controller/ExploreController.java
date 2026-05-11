package com.fellow4u.backend.controller;

import com.fellow4u.backend.dto.ExploreResponse;
import com.fellow4u.backend.service.ExploreService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/explore")
@RequiredArgsConstructor
public class ExploreController {
    private final ExploreService exploreService;

    @GetMapping
    public ResponseEntity<ExploreResponse> getExploreData() {
        return ResponseEntity.ok(exploreService.getExploreData());
    }

    @GetMapping("/guides")
    public ResponseEntity<?> getAllGuides() {
        return ResponseEntity.ok(exploreService.getAllGuides());
    }
}
