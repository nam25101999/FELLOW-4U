package com.fellow4u.backend.repository;

import com.fellow4u.backend.entity.Attraction;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface AttractionRepository extends JpaRepository<Attraction, String> {
    List<Attraction> findByCityContainingIgnoreCase(String city);
    List<Attraction> findByNameContainingIgnoreCase(String name);
}
