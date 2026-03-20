package com.jf.PetApp.infrastructure.controller.onboarding;

import com.jf.PetApp.application.onboarding.usecase.CalculateInvestorProfileUseCase;
import com.jf.PetApp.application.user.port.UserRepository;
import com.jf.PetApp.core.domain.assessment.InvestorProfile;
import com.jf.PetApp.core.domain.assessment.UserAssessment;
import com.jf.PetApp.core.domain.User;
import com.jf.PetApp.core.port.QuestionRepository;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/onboarding")
public class OnboardingController {

    private final QuestionRepository questionRepository;
    private final CalculateInvestorProfileUseCase calculateInvestorProfileUseCase;
    private final UserRepository userRepository;

    public OnboardingController(
            QuestionRepository questionRepository,
            CalculateInvestorProfileUseCase calculateInvestorProfileUseCase,
            UserRepository userRepository) {
        this.questionRepository = questionRepository;
        this.calculateInvestorProfileUseCase = calculateInvestorProfileUseCase;
        this.userRepository = userRepository;
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
        User user = resolveCurrentUser();

        // If the user already completed the onboarding, return their existing profile.
        if (user.hasAnsweredOnboarding() && user.getInvestorProfile() != null) {
            return ResponseEntity.ok(new ProfileResponseDTO(user.getInvestorProfile().name()));
        }

        UserAssessment assessment = new UserAssessment(user.getId(), request.selectedOptionIds());
        InvestorProfile profile = calculateInvestorProfileUseCase.execute(assessment);

        user.setHasAnsweredOnboarding(true);
        user.setInvestorProfile(profile);
        userRepository.save(user);

        return ResponseEntity.ok(new ProfileResponseDTO(profile.name()));
    }

    @GetMapping("/status")
    public ResponseEntity<OnboardingStatusDTO> getStatus() {
        User user = resolveCurrentUser();
        String profile = user.getInvestorProfile() == null ? null : user.getInvestorProfile().name();
        return ResponseEntity.ok(new OnboardingStatusDTO(user.hasAnsweredOnboarding(), profile));
    }

    private User resolveCurrentUser() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            throw new ResponseStatusException(org.springframework.http.HttpStatus.UNAUTHORIZED, "Not authenticated");
        }

        Object principal = authentication.getPrincipal();
        if (principal instanceof User domainUser) {
            return domainUser;
        }

        String email = null;
        if (principal instanceof UserDetails userDetails) {
            email = userDetails.getUsername();
        } else if (principal instanceof String principalString) {
            email = principalString;
        }

        if (email == null || email.isBlank()) {
            throw new ResponseStatusException(org.springframework.http.HttpStatus.UNAUTHORIZED, "User identity not available");
        }

        return userRepository.findByEmail(email)
                .orElseThrow(() -> new ResponseStatusException(org.springframework.http.HttpStatus.UNAUTHORIZED, "User not found"));
    }

    public record OptionResponseDTO(String id, String text) {}
    public record QuestionResponseDTO(String id, String text, List<OptionResponseDTO> options) {}
    public record SubmitAssessmentRequestDTO(List<String> selectedOptionIds) {}
    public record ProfileResponseDTO(String profile) {}
    public record OnboardingStatusDTO(boolean hasAnswered, String profile) {}
}
