package com.fellow4u.backend.dto.admin;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

public record AdminDashboardResponse(
        List<Metric> metrics,
        List<RevenuePoint> revenue,
        List<BookingSummary> recentBookings,
        List<TourSummary> topTours,
        List<GuideSummary> topGuides,
        List<ActivityItem> activities
) {
    public record Metric(String label, String value, String delta, String tone) {
    }

    public record RevenuePoint(String month, BigDecimal revenue) {
    }

    public record BookingSummary(
            String id,
            String tripTitle,
            String location,
            LocalDate date,
            String guideName,
            Integer travelers,
            BigDecimal totalFee,
            String status,
            String paymentStatus
    ) {
    }

    public record TourSummary(
            String id,
            String title,
            String location,
            String imageUrl,
            BigDecimal price,
            String category,
            Double rating,
            Integer reviewCount,
            Integer bookingRate,
            String description,
            String duration,
            LocalDate startDate
    ) {
    }

    public record GuideSummary(
            String id,
            String name,
            String location,
            String avatarUrl,
            Double rating,
            Integer activeTrips,
            Integer responseRate
    ) {
    }

    public record ActivityItem(String title, String meta, String tone) {
    }
}
