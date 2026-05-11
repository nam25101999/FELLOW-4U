package com.fellow4u.backend.repository;

import com.fellow4u.backend.entity.UserJourney;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface UserJourneyRepository extends JpaRepository<UserJourney, String> {
    List<UserJourney> findByUserId(String userId);
}
