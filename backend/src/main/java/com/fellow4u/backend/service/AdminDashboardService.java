package com.fellow4u.backend.service;

import com.fellow4u.backend.dto.admin.AdminDashboardResponse;
import com.fellow4u.backend.dto.admin.AdminTourRequest;
import com.fellow4u.backend.entity.Booking;
import com.fellow4u.backend.entity.Tour;
import com.fellow4u.backend.entity.User;
import com.fellow4u.backend.repository.BookingRepository;
import com.fellow4u.backend.repository.TourRepository;
import com.fellow4u.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.format.TextStyle;
import java.util.Comparator;
import java.util.List;
import java.util.Locale;
import java.util.Objects;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class AdminDashboardService {

    private final BookingRepository bookingRepository;
    private final TourRepository tourRepository;
    private final UserRepository userRepository;

    public AdminDashboardResponse getDashboard() {
        List<Booking> bookings = bookingRepository.findAll();
        List<Tour> tours = tourRepository.findAll();
        List<User> users = userRepository.findAll();
        List<User> guides = userRepository.findByRole("GUIDE");

        return new AdminDashboardResponse(
                buildMetrics(bookings, tours, users, guides),
                buildRevenue(bookings),
                getRecentBookings(bookings),
                getTopTours(tours, bookings),
                getTopGuides(guides, bookings),
                buildActivities(bookings, tours)
        );
    }

    public List<AdminDashboardResponse.BookingSummary> getRecentBookings() {
        return getRecentBookings(bookingRepository.findAll());
    }

    public List<AdminDashboardResponse.TourSummary> getTours() {
        List<Booking> bookings = bookingRepository.findAll();
        return tourRepository.findAll().stream()
                .sorted(Comparator.comparing(Tour::getStartDate, Comparator.nullsLast(Comparator.reverseOrder())))
                .map(tour -> toTourSummary(tour, bookings))
                .toList();
    }

    public AdminDashboardResponse.TourSummary getTour(String id) {
        List<Booking> bookings = bookingRepository.findAll();
        return tourRepository.findById(id)
                .map(tour -> toTourSummary(tour, bookings))
                .orElseThrow(() -> new IllegalArgumentException("Tour not found"));
    }

    @Transactional
    public AdminDashboardResponse.TourSummary createTour(AdminTourRequest request) {
        Tour tour = new Tour();
        applyTourRequest(tour, request);
        return toTourSummary(tourRepository.save(tour), bookingRepository.findAll());
    }

    @Transactional
    public AdminDashboardResponse.TourSummary updateTour(String id, AdminTourRequest request) {
        Tour tour = tourRepository.findById(id).orElseThrow(() -> new IllegalArgumentException("Tour not found"));
        applyTourRequest(tour, request);
        return toTourSummary(tourRepository.save(tour), bookingRepository.findAll());
    }

    @Transactional
    public void deleteTour(String id) {
        if (!tourRepository.existsById(id)) {
            throw new IllegalArgumentException("Tour not found");
        }
        tourRepository.deleteById(id);
    }

    public List<AdminDashboardResponse.GuideSummary> getGuides() {
        return getTopGuides(userRepository.findByRole("GUIDE"), bookingRepository.findAll());
    }

    private List<AdminDashboardResponse.Metric> buildMetrics(List<Booking> bookings, List<Tour> tours, List<User> users, List<User> guides) {
        BigDecimal revenue = bookings.stream()
                .map(this::paidAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        long unpaidCount = bookings.stream()
                .filter(booking -> "UNPAID".equals(booking.getPaymentStatus()))
                .count();

        long todayBookings = bookings.stream()
                .filter(booking -> Objects.equals(booking.getDate(), LocalDate.now()))
                .count();
        long savedWishlistCount = users.stream()
                .map(User::getBookmarkedTours)
                .filter(Objects::nonNull)
                .mapToLong(java.util.Set::size)
                .sum();

        return List.of(
                new AdminDashboardResponse.Metric("Total Tours", String.valueOf(tours.size()), activeTourCount(tours) + " active", "teal"),
                new AdminDashboardResponse.Metric("Saved to Wishlist Tours", String.valueOf(savedWishlistCount), users.size() + " users", "amber"),
                new AdminDashboardResponse.Metric("Revenue", "$" + revenue.setScale(0, RoundingMode.HALF_UP), revenueDelta(bookings), "blue"),
                new AdminDashboardResponse.Metric("Bookings", String.valueOf(bookings.size()), todayBookings + " today", "teal"),
                new AdminDashboardResponse.Metric("Open issues", String.valueOf(unpaidCount), unpaidCount + " unpaid", "coral")
        );
    }

    private List<AdminDashboardResponse.RevenuePoint> buildRevenue(List<Booking> bookings) {
        YearMonth currentMonth = YearMonth.now();

        return java.util.stream.IntStream.rangeClosed(0, 5)
                .mapToObj(index -> currentMonth.minusMonths(5L - index))
                .map(month -> {
                    BigDecimal revenue = bookings.stream()
                            .filter(booking -> booking.getDate() != null)
                            .filter(booking -> YearMonth.from(booking.getDate()).equals(month))
                            .map(this::paidAmount)
                            .reduce(BigDecimal.ZERO, BigDecimal::add);

                    String label = month.getMonth().getDisplayName(TextStyle.SHORT, Locale.ENGLISH);
                    return new AdminDashboardResponse.RevenuePoint(label, revenue);
                })
                .toList();
    }

    private List<AdminDashboardResponse.BookingSummary> getRecentBookings(List<Booking> bookings) {
        return bookings.stream()
                .sorted(Comparator.comparing(Booking::getDate, Comparator.nullsLast(Comparator.reverseOrder())))
                .limit(8)
                .map(this::toBookingSummary)
                .toList();
    }

    private List<AdminDashboardResponse.TourSummary> getTopTours(List<Tour> tours, List<Booking> bookings) {
        return tours.stream()
                .sorted(Comparator
                        .comparing((Tour tour) -> bookingCountForTour(tour, bookings)).reversed()
                        .thenComparing(Tour::getRating, Comparator.nullsLast(Comparator.reverseOrder())))
                .limit(12)
                .map(tour -> toTourSummary(tour, bookings))
                .toList();
    }

    private List<AdminDashboardResponse.GuideSummary> getTopGuides(List<User> guides, List<Booking> bookings) {
        return guides.stream()
                .limit(12)
                .map(guide -> toGuideSummary(guide, bookings))
                .toList();
    }

    private List<AdminDashboardResponse.ActivityItem> buildActivities(List<Booking> bookings, List<Tour> tours) {
        long unpaidCount = bookings.stream()
                .filter(booking -> "UNPAID".equals(booking.getPaymentStatus()))
                .count();

        String newestBookingTitle = bookings.stream()
                .max(Comparator.comparing(Booking::getDate, Comparator.nullsLast(Comparator.naturalOrder())))
                .map(Booking::getTripTitle)
                .orElse("No bookings yet");

        String topTourTitle = tours.stream()
                .max(Comparator.comparing(Tour::getRating, Comparator.nullsLast(Comparator.naturalOrder())))
                .map(Tour::getTitle)
                .orElse("No tours yet");

        return List.of(
                new AdminDashboardResponse.ActivityItem("New booking received", newestBookingTitle, "teal"),
                new AdminDashboardResponse.ActivityItem("Payment review queue", unpaidCount + " unpaid bookings", unpaidCount > 0 ? "amber" : "teal"),
                new AdminDashboardResponse.ActivityItem("Top rated tour", topTourTitle, "blue"),
                new AdminDashboardResponse.ActivityItem("Tours in inventory", tours.size() + " tours", "teal")
        );
    }

    private AdminDashboardResponse.BookingSummary toBookingSummary(Booking booking) {
        return new AdminDashboardResponse.BookingSummary(
                booking.getId(),
                booking.getTripTitle(),
                booking.getLocation(),
                booking.getDate(),
                booking.getGuideName(),
                booking.getTravelers(),
                booking.getTotalFee(),
                booking.getStatus(),
                booking.getPaymentStatus()
        );
    }

    private AdminDashboardResponse.TourSummary toTourSummary(Tour tour, List<Booking> bookings) {
        String category = tour.getCategory() == null ? "REGULAR" : tour.getCategory().name();
        int bookingRate = bookingRateForTour(tour, bookings);

        return new AdminDashboardResponse.TourSummary(
                tour.getId(),
                tour.getTitle(),
                tour.getLocation(),
                tour.getImageUrl(),
                tour.getPrice(),
                category,
                tour.getRating(),
                tour.getReviewCount(),
                bookingRate,
                tour.getDescription(),
                tour.getDuration(),
                tour.getStartDate()
        );
    }

    private void applyTourRequest(Tour tour, AdminTourRequest request) {
        tour.setTitle(request.title());
        tour.setDescription(request.description());
        tour.setImageUrl(request.imageUrl());
        tour.setPrice(request.price());
        tour.setLocation(request.location());
        tour.setDuration(request.duration());
        tour.setStartDate(request.startDate());
        tour.setRating(request.rating());
        tour.setReviewCount(request.reviewCount());
        tour.setCategory(parseCategory(request.category()));
    }

    private Tour.TourCategory parseCategory(String category) {
        if (category == null || category.isBlank()) {
            return Tour.TourCategory.REGULAR;
        }

        try {
            return Tour.TourCategory.valueOf(category.trim().toUpperCase(Locale.ENGLISH));
        } catch (IllegalArgumentException exception) {
            return Tour.TourCategory.REGULAR;
        }
    }

    private AdminDashboardResponse.GuideSummary toGuideSummary(User guide, List<Booking> bookings) {
        String guideName = fullName(guide);
        long totalTrips = bookings.stream()
                .filter(booking -> guideName.equalsIgnoreCase(booking.getGuideName()))
                .count();
        int activeTrips = (int) bookings.stream()
                .filter(booking -> guideName.equalsIgnoreCase(booking.getGuideName()))
                .filter(booking -> booking.getDate() == null || !booking.getDate().isBefore(LocalDate.now()))
                .count();
        long paidTrips = bookings.stream()
                .filter(booking -> guideName.equalsIgnoreCase(booking.getGuideName()))
                .filter(booking -> "PAID_50".equals(booking.getPaymentStatus()) || "PAID_100".equals(booking.getPaymentStatus()))
                .count();

        return new AdminDashboardResponse.GuideSummary(
                guide.getId(),
                guideName,
                guide.getLocation(),
                guide.getAvatarUrl(),
                guideRatingFromBookings(totalTrips, paidTrips),
                activeTrips,
                percentage(paidTrips, totalTrips)
        );
    }

    private String fullName(User user) {
        return ((user.getFirstName() == null ? "" : user.getFirstName()) + " "
                + (user.getLastName() == null ? "" : user.getLastName())).trim();
    }

    private BigDecimal paidAmount(Booking booking) {
        if (booking.getTotalFee() == null || booking.getPaymentStatus() == null) {
            return BigDecimal.ZERO;
        }

        if ("PAID_50".equals(booking.getPaymentStatus())) {
            return booking.getTotalFee().multiply(BigDecimal.valueOf(0.5));
        }

        if ("PAID_100".equals(booking.getPaymentStatus())) {
            return booking.getTotalFee();
        }

        return BigDecimal.ZERO;
    }

    private String revenueDelta(List<Booking> bookings) {
        YearMonth currentMonth = YearMonth.now();
        BigDecimal current = revenueForMonth(bookings, currentMonth);
        BigDecimal previous = revenueForMonth(bookings, currentMonth.minusMonths(1));

        if (previous.compareTo(BigDecimal.ZERO) == 0) {
            return current.compareTo(BigDecimal.ZERO) == 0 ? "0%" : "+100%";
        }

        BigDecimal delta = current.subtract(previous)
                .multiply(BigDecimal.valueOf(100))
                .divide(previous, 1, RoundingMode.HALF_UP);
        return (delta.compareTo(BigDecimal.ZERO) >= 0 ? "+" : "") + delta + "%";
    }

    private BigDecimal revenueForMonth(List<Booking> bookings, YearMonth month) {
        return bookings.stream()
                .filter(booking -> booking.getDate() != null)
                .filter(booking -> YearMonth.from(booking.getDate()).equals(month))
                .map(this::paidAmount)
                .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    private long activeTourCount(List<Tour> tours) {
        return tours.stream()
                .filter(tour -> tour.getStartDate() == null || !tour.getStartDate().isBefore(LocalDate.now()))
                .count();
    }

    private int bookingRateForTour(Tour tour, List<Booking> bookings) {
        return percentage(bookingCountForTour(tour, bookings), bookings.size());
    }

    private long bookingCountForTour(Tour tour, List<Booking> bookings) {
        String title = normalize(tour.getTitle());
        if (title.isBlank()) {
            return 0;
        }

        return bookings.stream()
                .filter(booking -> normalize(booking.getTripTitle()).equals(title))
                .count();
    }

    private Double guideRatingFromBookings(long totalTrips, long paidTrips) {
        if (totalTrips == 0) {
            return 0.0;
        }
        return BigDecimal.valueOf(5.0)
                .multiply(BigDecimal.valueOf(paidTrips))
                .divide(BigDecimal.valueOf(totalTrips), 1, RoundingMode.HALF_UP)
                .doubleValue();
    }

    private int percentage(long part, long total) {
        if (total <= 0) {
            return 0;
        }
        return BigDecimal.valueOf(part)
                .multiply(BigDecimal.valueOf(100))
                .divide(BigDecimal.valueOf(total), 0, RoundingMode.HALF_UP)
                .intValue();
    }

    private String normalize(String value) {
        return value == null ? "" : value.trim().toLowerCase(Locale.ENGLISH);
    }
}
