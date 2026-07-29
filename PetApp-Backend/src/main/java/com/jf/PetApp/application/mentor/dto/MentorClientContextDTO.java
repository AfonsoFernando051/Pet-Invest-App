package com.jf.PetApp.application.mentor.dto;

/**
 * Signals only the mobile client knows (local pet preferences, current screen, UI language) —
 * everything else (portfolio, pet) is loaded server-side from the authenticated user.
 */
public record MentorClientContextDTO(
    String petGoal,
    String investmentHorizon,
    String currentScreen,
    String language
) {
}
