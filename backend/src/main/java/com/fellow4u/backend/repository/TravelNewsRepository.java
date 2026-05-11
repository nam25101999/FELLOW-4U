package com.fellow4u.backend.repository;

import com.fellow4u.backend.entity.TravelNews;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TravelNewsRepository extends JpaRepository<TravelNews, String> {
}
