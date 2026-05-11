package com.fellow4u.backend.dto.admin;

import java.math.BigDecimal;
import java.time.LocalDate;

public record AdminTourRequest(
        String title,
        String description,
        String imageUrl,
        BigDecimal price,
        String location,
        String duration,
        LocalDate startDate,
        Double rating,
        Integer reviewCount,
        String category
) {
}
