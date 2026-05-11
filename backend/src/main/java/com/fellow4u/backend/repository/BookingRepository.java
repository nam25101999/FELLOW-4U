package com.fellow4u.backend.repository;

import com.fellow4u.backend.entity.Booking;
import com.fellow4u.backend.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface BookingRepository extends JpaRepository<Booking, String> {
    List<Booking> findByStatus(String status);
    List<Booking> findByUser(User user);
    List<Booking> findByUserAndStatus(User user, String status);
    long countByStatus(String status);
    long countByPaymentStatus(String paymentStatus);
}
