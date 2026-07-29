package com.jf.PetApp.application.mentor.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

import java.util.List;

public record MentorChatRequest(
    @NotBlank @Size(max = 2000) String message,
    List<MentorTurnDTO> history,
    @Valid MentorClientContextDTO context
) {
}
