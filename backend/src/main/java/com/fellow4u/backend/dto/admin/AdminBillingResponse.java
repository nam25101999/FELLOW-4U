package com.fellow4u.backend.dto.admin;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

public record AdminBillingResponse(
        List<Invoice> invoices,
        PaymentInfo paymentInfo,
        Subscription subscription,
        List<Plan> plans
) {
    public record Invoice(
            String billId,
            String billName,
            LocalDate date,
            BigDecimal amount
    ) {
    }

    public record PaymentInfo(
            String id,
            String cardHolderName,
            String cardNumberMasked,
            String provider,
            String type
    ) {
    }

    public record Subscription(
            String planName,
            BigDecimal yearlyPrice,
            LocalDate startedAt,
            LocalDate validUntil
    ) {
    }

    public record Plan(
            String name,
            BigDecimal yearlyPrice,
            String description,
            boolean selected
    ) {
    }
}
