package com.jf.PetApp.application.mentor.usecase;

import com.jf.PetApp.application.investment.dto.AllocationSliceDTO;
import com.jf.PetApp.application.investment.dto.PortfolioSummaryDTO;
import com.jf.PetApp.application.investment.usecase.GetPortfolioAllocationUseCase;
import com.jf.PetApp.application.investment.usecase.GetPortfolioSummaryUseCase;
import com.jf.PetApp.application.mentor.dto.MentorChatRequest;
import com.jf.PetApp.application.mentor.dto.MentorTurnDTO;
import com.jf.PetApp.application.mentor.port.GeminiChatPort;
import com.jf.PetApp.application.mentor.prompt.MentorSystemPromptBuilder;
import com.jf.PetApp.application.pet.usecase.GetMyPetUseCase;
import com.jf.PetApp.application.user.port.UserRepository;
import com.jf.PetApp.core.domain.Pet;
import com.jf.PetApp.core.domain.User;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class GetMentorReplyUseCaseImpl implements GetMentorReplyUseCase {

    private static final Logger log = LoggerFactory.getLogger(GetMentorReplyUseCaseImpl.class);
    private static final int MAX_HISTORY_TURNS = 10;
    private static final String FALLBACK_REPLY =
            "Hmm, I'm having a little trouble thinking right now 🐾 Let's try again in a moment.";

    private final UserRepository userRepository;
    private final GetPortfolioSummaryUseCase getPortfolioSummaryUseCase;
    private final GetPortfolioAllocationUseCase getPortfolioAllocationUseCase;
    private final GetMyPetUseCase getMyPetUseCase;
    private final GeminiChatPort geminiChatPort;

    public GetMentorReplyUseCaseImpl(UserRepository userRepository,
                                      GetPortfolioSummaryUseCase getPortfolioSummaryUseCase,
                                      GetPortfolioAllocationUseCase getPortfolioAllocationUseCase,
                                      GetMyPetUseCase getMyPetUseCase,
                                      GeminiChatPort geminiChatPort) {
        this.userRepository = userRepository;
        this.getPortfolioSummaryUseCase = getPortfolioSummaryUseCase;
        this.getPortfolioAllocationUseCase = getPortfolioAllocationUseCase;
        this.getMyPetUseCase = getMyPetUseCase;
        this.geminiChatPort = geminiChatPort;
    }

    @Override
    public String execute(String email, MentorChatRequest request) {
        User user = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("User not found"));

        PortfolioSummaryDTO summary = getPortfolioSummaryUseCase.execute(email);
        List<AllocationSliceDTO> allocation = getPortfolioAllocationUseCase.execute(email);
        Pet pet = getMyPetUseCase.execute(email).orElse(null);

        String systemPrompt = MentorSystemPromptBuilder.build(
                pet, summary, allocation, request.context(), user.getPreferredLanguage());

        List<MentorTurnDTO> history = trimHistory(request.history());

        try {
            return geminiChatPort.generateReply(systemPrompt, history, request.message());
        } catch (Exception e) {
            // e.getMessage() here is safe to log: GeminiChatClient never lets the API key
            // reach an exception message (see its own catch block).
            log.warn("Gemini call failed, falling back to canned reply: {}", e.getMessage());
            return FALLBACK_REPLY;
        }
    }

    private List<MentorTurnDTO> trimHistory(List<MentorTurnDTO> history) {
        if (history == null || history.isEmpty()) {
            return List.of();
        }
        int fromIndex = Math.max(0, history.size() - MAX_HISTORY_TURNS);
        return history.subList(fromIndex, history.size());
    }
}
