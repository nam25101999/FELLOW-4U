package com.fellow4u.backend.controller;

import com.fellow4u.backend.entity.Booking;
import com.fellow4u.backend.entity.User;
import com.fellow4u.backend.repository.BookingRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/bookings")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class BookingController {

    private final BookingRepository bookingRepository;

    @GetMapping
    public ResponseEntity<List<Booking>> getAllBookings(@AuthenticationPrincipal User user) {
        return ResponseEntity.ok(bookingRepository.findByUser(user));
    }

    @GetMapping("/status/{status}")
    public ResponseEntity<List<Booking>> getBookingsByStatus(
            @AuthenticationPrincipal User user,
            @PathVariable String status) {
        return ResponseEntity.ok(bookingRepository.findByUserAndStatus(user, status));
    }
}
