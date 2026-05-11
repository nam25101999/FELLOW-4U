package com.fellow4u.backend.dto.admin;

public record AdminPaymentUpdateRequest(
        String cardHolderName,
        String cardNumber,
        String provider
) {
}
