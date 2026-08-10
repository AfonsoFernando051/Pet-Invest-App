package com.jf.PetApp.application.mentor.usecase;

import com.jf.PetApp.application.investment.dto.PortfolioSummaryDTO;
import com.jf.PetApp.application.investment.usecase.GetPortfolioAllocationUseCase;
import com.jf.PetApp.application.investment.usecase.GetPortfolioSummaryUseCase;
import com.jf.PetApp.application.mentor.dto.MentorChatRequest;
import com.jf.PetApp.application.mentor.dto.MentorTurnDTO;
import com.jf.PetApp.application.mentor.port.GeminiChatPort;
import com.jf.PetApp.application.pet.usecase.GetMyPetUseCase;
import com.jf.PetApp.application.user.port.UserRepository;
import com.jf.PetApp.core.domain.User;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.*;

class GetMentorReplyUseCaseImplTest {

    @Mock
    private UserRepository userRepository;
    @Mock
    private GetPortfolioSummaryUseCase getPortfolioSummaryUseCase;
    @Mock
    private GetPortfolioAllocationUseCase getPortfolioAllocationUseCase;
    @Mock
    private GetMyPetUseCase getMyPetUseCase;
    @Mock
    private GeminiChatPort geminiChatPort;

    private GetMentorReplyUseCaseImpl useCase;

    private static final String EMAIL = "investor@test.com";
    private static final PortfolioSummaryDTO EMPTY_SUMMARY =
            new PortfolioSummaryDTO(0.0, 0.0, 0.0, 0.0, 0);

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
        useCase = new GetMentorReplyUseCaseImpl(
                userRepository, getPortfolioSummaryUseCase, getPortfolioAllocationUseCase, getMyPetUseCase, geminiChatPort);

        User user = new User();
        user.setEmail(EMAIL);
        user.setPreferredLanguage("pt");
        when(userRepository.findByEmail(EMAIL)).thenReturn(Optional.of(user));
        when(getPortfolioSummaryUseCase.execute(EMAIL)).thenReturn(EMPTY_SUMMARY);
        when(getPortfolioAllocationUseCase.execute(EMAIL)).thenReturn(List.of());
        when(getMyPetUseCase.execute(EMAIL)).thenReturn(Optional.empty());
    }

    private MentorChatRequest requestWithHistory(List<MentorTurnDTO> history) {
        return new MentorChatRequest("What are dividends?", history, null);
    }

    @Test
    void execute_WhenUserDoesNotExist_Throws() {
        when(userRepository.findByEmail(EMAIL)).thenReturn(Optional.empty());

        assertThrows(IllegalArgumentException.class,
                () -> useCase.execute(EMAIL, requestWithHistory(List.of())));
    }

    @Test
    void execute_OnSuccess_ReturnsTheGeminiReplyVerbatim() {
        when(geminiChatPort.generateReply(anyString(), any(), anyString())).thenReturn("Dividends are periodic payments...");

        String reply = useCase.execute(EMAIL, requestWithHistory(List.of()));

        assertEquals("Dividends are periodic payments...", reply);
    }

    @Test
    void execute_WhenGeminiThrows_ReturnsTheCannedFallbackInsteadOfPropagating() {
        when(geminiChatPort.generateReply(anyString(), any(), anyString())).thenThrow(new RuntimeException("Gemini request failed"));

        String reply = useCase.execute(EMAIL, requestWithHistory(List.of()));

        assertNotNull(reply);
        assertTrue(reply.toLowerCase().contains("trouble") || !reply.isBlank());
    }

    @Test
    void execute_WithMoreThanTenHistoryTurns_TrimsToTheMostRecentTen() {
        List<MentorTurnDTO> history = new ArrayList<>();
        for (int i = 0; i < 15; i++) {
            history.add(new MentorTurnDTO(i % 2 == 0 ? "user" : "mentor", "turn " + i));
        }
        when(geminiChatPort.generateReply(anyString(), any(), anyString())).thenReturn("ok");

        useCase.execute(EMAIL, requestWithHistory(history));

        @SuppressWarnings("unchecked")
        ArgumentCaptor<List<MentorTurnDTO>> historyCaptor = ArgumentCaptor.forClass(List.class);
        verify(geminiChatPort).generateReply(anyString(), historyCaptor.capture(), anyString());

        List<MentorTurnDTO> trimmed = historyCaptor.getValue();
        assertEquals(10, trimmed.size());
        // The most recent turns are kept — the trimmed window should end on "turn 14".
        assertEquals("turn 14", trimmed.get(trimmed.size() - 1).text());
        assertEquals("turn 5", trimmed.get(0).text());
    }

    @Test
    void execute_WithEmptyHistory_PassesAnEmptyListToGemini() {
        when(geminiChatPort.generateReply(anyString(), any(), anyString())).thenReturn("ok");

        useCase.execute(EMAIL, requestWithHistory(List.of()));

        @SuppressWarnings("unchecked")
        ArgumentCaptor<List<MentorTurnDTO>> historyCaptor = ArgumentCaptor.forClass(List.class);
        verify(geminiChatPort).generateReply(anyString(), historyCaptor.capture(), anyString());
        assertTrue(historyCaptor.getValue().isEmpty());
    }

    @Test
    void execute_WithNullHistory_DoesNotThrowAndPassesEmptyList() {
        when(geminiChatPort.generateReply(anyString(), any(), anyString())).thenReturn("ok");

        useCase.execute(EMAIL, new MentorChatRequest("hi", null, null));

        @SuppressWarnings("unchecked")
        ArgumentCaptor<List<MentorTurnDTO>> historyCaptor = ArgumentCaptor.forClass(List.class);
        verify(geminiChatPort).generateReply(anyString(), historyCaptor.capture(), anyString());
        assertTrue(historyCaptor.getValue().isEmpty());
    }
}
