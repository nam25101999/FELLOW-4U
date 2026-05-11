package com.fellow4u.backend.dto.admin;

public record AdminEmailTemplateResponse(
        String subject,
        String logoText,
        String title,
        String body,
        String buttonLabel,
        String buttonUrl,
        String footer
) {
}
