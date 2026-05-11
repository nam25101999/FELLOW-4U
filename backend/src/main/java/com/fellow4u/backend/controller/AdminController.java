package com.fellow4u.backend.controller;

import com.fellow4u.backend.dto.admin.AdminBillingResponse;
import com.fellow4u.backend.dto.admin.AdminDashboardResponse;
import com.fellow4u.backend.dto.admin.AdminEmailTemplateResponse;
import com.fellow4u.backend.dto.admin.AdminChatResponse;
import com.fellow4u.backend.dto.admin.AdminChatSendRequest;
import com.fellow4u.backend.dto.admin.AdminPaymentUpdateRequest;
import com.fellow4u.backend.dto.admin.AdminPlanUpdateRequest;
import com.fellow4u.backend.dto.admin.AdminTourRequest;
import com.fellow4u.backend.service.AdminBillingService;
import com.fellow4u.backend.service.AdminChatService;
import com.fellow4u.backend.service.AdminDashboardService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
public class AdminController {

    private final AdminDashboardService adminDashboardService;
    private final AdminChatService adminChatService;
    private final AdminBillingService adminBillingService;

    @GetMapping("/dashboard")
    public ResponseEntity<AdminDashboardResponse> getDashboard() {
        return ResponseEntity.ok(adminDashboardService.getDashboard());
    }

    @GetMapping("/bookings")
    public ResponseEntity<List<AdminDashboardResponse.BookingSummary>> getBookings() {
        return ResponseEntity.ok(adminDashboardService.getRecentBookings());
    }

    @GetMapping("/tours")
    public ResponseEntity<List<AdminDashboardResponse.TourSummary>> getTours() {
        return ResponseEntity.ok(adminDashboardService.getTours());
    }

    @GetMapping("/tours/{id}")
    public ResponseEntity<AdminDashboardResponse.TourSummary> getTour(@PathVariable String id) {
        return ResponseEntity.ok(adminDashboardService.getTour(id));
    }

    @PostMapping("/tours")
    public ResponseEntity<AdminDashboardResponse.TourSummary> createTour(@RequestBody AdminTourRequest request) {
        return ResponseEntity.ok(adminDashboardService.createTour(request));
    }

    @PutMapping("/tours/{id}")
    public ResponseEntity<AdminDashboardResponse.TourSummary> updateTour(
            @PathVariable String id,
            @RequestBody AdminTourRequest request
    ) {
        return ResponseEntity.ok(adminDashboardService.updateTour(id, request));
    }

    @DeleteMapping("/tours/{id}")
    public ResponseEntity<Void> deleteTour(@PathVariable String id) {
        adminDashboardService.deleteTour(id);
        return ResponseEntity.noContent().build();
    }

    @GetMapping("/guides")
    public ResponseEntity<List<AdminDashboardResponse.GuideSummary>> getGuides() {
        return ResponseEntity.ok(adminDashboardService.getGuides());
    }

    @GetMapping("/chat")
    public ResponseEntity<AdminChatResponse> getChat(@RequestParam(required = false) String userId) {
        return ResponseEntity.ok(adminChatService.getChat(userId));
    }

    @PostMapping("/chat/messages")
    public ResponseEntity<AdminChatResponse.Message> sendChatMessage(@RequestBody AdminChatSendRequest request) {
        return ResponseEntity.ok(adminChatService.send(request));
    }

    @GetMapping("/billing")
    public ResponseEntity<AdminBillingResponse> getBilling() {
        return ResponseEntity.ok(adminBillingService.getBilling());
    }

    @PutMapping("/billing/payment")
    public ResponseEntity<AdminBillingResponse> updatePayment(@RequestBody AdminPaymentUpdateRequest request) {
        return ResponseEntity.ok(adminBillingService.updatePayment(request));
    }

    @PutMapping("/billing/plan")
    public ResponseEntity<AdminBillingResponse> updatePlan(@RequestBody AdminPlanUpdateRequest request) {
        return ResponseEntity.ok(adminBillingService.updatePlan(request));
    }

    @GetMapping("/email-templates/password-reset")
    public ResponseEntity<AdminEmailTemplateResponse> getPasswordResetTemplate() {
        return ResponseEntity.ok(new AdminEmailTemplateResponse(
                "Reset your Fellow4U admin password",
                "Fellow4U",
                "Reset password instructions",
                "We received a request to reset your admin password. Use the button below to continue. This link is valid for a limited time.",
                "Reset password",
                "https://fellow4u.app/admin/reset-password",
                "If you did not request this, you can safely ignore this email."
        ));
    }
}
