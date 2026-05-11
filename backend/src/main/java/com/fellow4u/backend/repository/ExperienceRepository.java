package com.fellow4u.backend.repository;

import com.fellow4u.backend.entity.Experience;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ExperienceRepository extends JpaRepository<Experience, String> {
    List<Experience> findByTitleContainingIgnoreCase(String title);
}
