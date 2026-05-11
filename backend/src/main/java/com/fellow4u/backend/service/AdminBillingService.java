package com.fellow4u.backend.service;

import com.fellow4u.backend.dto.admin.AdminBillingResponse;
import com.fellow4u.backend.dto.admin.AdminPaymentUpdateRequest;
import com.fellow4u.backend.dto.admin.AdminPlanUpdateRequest;
import com.fellow4u.backend.entity.AdminSubscription;
import com.fellow4u.backend.entity.Booking;
import com.fellow4u.backend.entity.PaymentMethod;
import com.fellow4u.backend.entity.User;
import com.fellow4u.backend.repository.AdminSubscriptionRepository;
import com.fellow4u.backend.repository.BookingRepository;
import com.fellow4u.backend.repository.PaymentMethodRepository;
import com.fellow4u.backend.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.Comparator;
import java.util.List;

@Service
@RequiredArgsConstructor
public class AdminBillingService {

    private final BookingRepository bookingRepository;
    private final PaymentMethodRepository paymentMethodRepository;
    private final AdminSubscriptionRepository subscriptionRepository;
    private final UserRepository userRepository;

    @Transactional(readOnly = true)
    public AdminBillingResponse getBilling() {
        User admin = currentAdmin();
        AdminSubscription subscription = currentSubscription(admin);
        return new AdminBillingResponse(
                invoices(),
                paymentInfo(admin),
                toSubscription(subscription),
                plans(subscription.getPlanName())
        );
    }

    @Transactional
    public AdminBillingResponse updatePayment(AdminPaymentUpdateRequest request) {
        User admin = currentAdmin();
        PaymentMethod method = paymentMethodRepository.findByUser(admin).stream()
                .filter(item -> "CARD".equalsIgnoreCase(item.getType()))
                .findFirst()
                .orElseGet(() -> PaymentMethod.builder().user(admin).type("CARD").build());

        String lastFour = lastFour(request.cardNumber());
        method.setName((request.provider() == null || request.provider().isBlank() ? "Visa" : request.provider()) + " **** " + lastFour);
        method.setIdentifier("**** **** **** " + lastFour);
        method.setProvider(request.provider() == null || request.provider().isBlank() ? "VISA" : request.provider().toUpperCase());
        paymentMethodRepository.save(method);
        return getBilling();
    }

    @Transactional
    public AdminBillingResponse updatePlan(AdminPlanUpdateRequest request) {
        User admin = currentAdmin();
        AdminBillingResponse.Plan plan = plans("").stream()
                .filter(item -> item.name().equalsIgnoreCase(request.planName()))
                .findFirst()
                .orElseThrow(() -> new IllegalArgumentException("Plan not found"));

        AdminSubscription subscription = currentSubscription(admin);
        subscription.setPlanName(plan.name());
        subscription.setYearlyPrice(plan.yearlyPrice());
        subscription.setStartedAt(LocalDate.now());
        subscription.setValidUntil(LocalDate.now().plusYears(1));
        subscriptionRepository.save(subscription);
        return getBilling();
    }

    private List<AdminBillingResponse.Invoice> invoices() {
        return bookingRepository.findAll().stream()
                .filter(booking -> "PAID_50".equals(booking.getPaymentStatus()) || "PAID_100".equals(booking.getPaymentStatus()))
                .sorted(Comparator.comparing(Booking::getDate, Comparator.nullsLast(Comparator.reverseOrder())))
                .limit(20)
                .map(booking -> new AdminBillingResponse.Invoice(
                        shortBillId(booking.getId()),
                        booking.getTripTitle(),
                        booking.getDate(),
                        paidAmount(booking)
                ))
                .toList();
    }

    private AdminBillingResponse.PaymentInfo paymentInfo(User admin) {
        return paymentMethodRepository.findByUser(admin).stream()
                .filter(method -> "CARD".equalsIgnoreCase(method.getType()))
                .findFirst()
                .map(method -> new AdminBillingResponse.PaymentInfo(
                        method.getId(),
                        admin.getFirstName() + " " + admin.getLastName(),
                        method.getIdentifier(),
                        method.getProvider(),
                        method.getType()
                ))
                .orElse(new AdminBillingResponse.PaymentInfo(null, admin.getFirstName() + " " + admin.getLastName(), "", "", "CARD"));
    }

    private AdminSubscription currentSubscription(User admin) {
        return subscriptionRepository.findFirstByAdminUserOrderByStartedAtDesc(admin)
                .orElseGet(() -> subscriptionRepository.save(AdminSubscription.builder()
                        .adminUser(admin)
                        .planName("Starter")
                        .yearlyPrice(BigDecimal.valueOf(100))
                        .startedAt(LocalDate.now().minusMonths(2))
                        .validUntil(LocalDate.now().plusMonths(10))
                        .build()));
    }

    private AdminBillingResponse.Subscription toSubscription(AdminSubscription subscription) {
        return new AdminBillingResponse.Subscription(
                subscription.getPlanName(),
                subscription.getYearlyPrice(),
                subscription.getStartedAt(),
                subscription.getValidUntil()
        );
    }

    private List<AdminBillingResponse.Plan> plans(String selectedPlan) {
        return List.of(
                new AdminBillingResponse.Plan("Starter", BigDecimal.valueOf(100), "Manage essential tours, billing history, and traveler support.", "Starter".equalsIgnoreCase(selectedPlan)),
                new AdminBillingResponse.Plan("Basic", BigDecimal.valueOf(120), "Adds stronger tour operations, more reporting, and payment workflow support.", "Basic".equalsIgnoreCase(selectedPlan)),
                new AdminBillingResponse.Plan("Premium", BigDecimal.valueOf(180), "Full admin package with advanced inventory, support, and billing features.", "Premium".equalsIgnoreCase(selectedPlan))
        );
    }

    private BigDecimal paidAmount(Booking booking) {
        if (booking.getTotalFee() == null) {
            return BigDecimal.ZERO;
        }
        if ("PAID_50".equals(booking.getPaymentStatus())) {
            return booking.getTotalFee().multiply(BigDecimal.valueOf(0.5));
        }
        return booking.getTotalFee();
    }

    private String shortBillId(String id) {
        return "EXP - " + (id == null ? "0000" : id.substring(0, Math.min(4, id.length())).toUpperCase());
    }

    private String lastFour(String value) {
        String digits = value == null ? "" : value.replaceAll("\\D", "");
        return digits.length() <= 4 ? digits : digits.substring(digits.length() - 4);
    }

    private User currentAdmin() {
        String email = SecurityContextHolder.getContext().getAuthentication().getName();
        return userRepository.findByEmail(email).orElseThrow(() -> new IllegalStateException("Admin user not found"));
    }
}
