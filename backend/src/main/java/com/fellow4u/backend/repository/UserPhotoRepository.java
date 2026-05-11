package com.fellow4u.backend.repository;

import com.fellow4u.backend.entity.UserPhoto;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface UserPhotoRepository extends JpaRepository<UserPhoto, String> {
    List<UserPhoto> findByUserId(String userId);
}
