package com.fellow4u.backend.repository;

import com.fellow4u.backend.entity.Tour;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface TourRepository extends JpaRepository<Tour, String> {
    List<Tour> findByCategory(Tour.TourCategory category);
    List<Tour> findByTitleContainingIgnoreCase(String title);
    long countByCategory(Tour.TourCategory category);
}
