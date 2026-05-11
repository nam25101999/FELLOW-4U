package com.fellow4u.backend.controller;

import com.fellow4u.backend.dto.ExploreResponse;
import com.fellow4u.backend.service.SearchService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/search")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class SearchController {
    private final SearchService searchService;

    @GetMapping
    public ResponseEntity<ExploreResponse> search(@RequestParam String q) {
        return ResponseEntity.ok(searchService.search(q));
    }
}
