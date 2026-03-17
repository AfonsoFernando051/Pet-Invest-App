package com.jf.PetApp.infrastructure.controller.onboarding;

import com.jf.PetApp.application.onboarding.usecase.CalculateInvestorProfileUseCase;
import com.jf.PetApp.core.domain.assessment.InvestorProfile;
import com.jf.PetApp.core.domain.assessment.UserAssessment;
import com.jf.PetApp.core.port.QuestionRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/onboarding")
public class OnboardingController {

    private final QuestionRepository questionRepository;
    private final CalculateInvestorProfileUseCase calculateInvestorProfileUseCase;

    public OnboardingController(
            QuestionRepository questionRepository,
            CalculateInvestorProfileUseCase calculateInvestorProfileUseCase) {
        this.questionRepository = questionRepository;
        this.calculateInvestorProfileUseCase = calculateInvestorProfileUseCase;
    }

    @GetMapping("/questions")
    public ResponseEntity<List<QuestionResponseDTO>> getQuestions() {
        List<QuestionResponseDTO> responses = questionRepository.findAll().stream()
                .map(q -> new QuestionResponseDTO(
                        q.id(),
                        q.text(),
                        q.options().stream()
                                .map(o -> new OptionResponseDTO(o.id(), o.text()))
                                .collect(Collectors.toList())
                ))
                .collect(Collectors.toList());

        return ResponseEntity.ok(responses);
    }

    @PostMapping("/submit")
    public ResponseEntity<ProfileResponseDTO> submitAssessment(@RequestBody SubmitAssessmentRequestDTO request) {
        // In a real application, the User ID would be resolved from the SecurityContext
        Long dummyUserId = 1L; 
        
        UserAssessment assessment = new UserAssessment(dummyUserId, request.selectedOptionIds());
        InvestorProfile profile = calculateInvestorProfileUseCase.execute(assessment);

        return ResponseEntity.ok(new ProfileResponseDTO(profile.name()));
    }

    public record OptionResponseDTO(String id, String text) {}
    public record QuestionResponseDTO(String id, String text, List<OptionResponseDTO> options) {}
    public record SubmitAssessmentRequestDTO(List<String> selectedOptionIds) {}
    public record ProfileResponseDTO(String profile) {}
}
