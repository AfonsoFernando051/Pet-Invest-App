package com.jf.PetApp.infrastructure.controller.settings;

import com.jf.PetApp.application.translation.service.TranslationCacheService;
import com.jf.PetApp.application.user.port.UserRepository;
import com.jf.PetApp.core.domain.User;
import com.jf.PetApp.core.security.SecurityUtils;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api/settings")
public class SettingsController {

    private final UserRepository userRepository;

    public SettingsController(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @GetMapping("/language")
    public ResponseEntity<LanguageResponseDTO> getLanguage() {
        User user = resolveCurrentUser();
        return ResponseEntity.ok(new LanguageResponseDTO(user.getPreferredLanguage()));
    }

    @PutMapping("/language")
    public ResponseEntity<LanguageResponseDTO> updateLanguage(@RequestBody UpdateLanguageRequestDTO request) {
        if (!TranslationCacheService.SUPPORTED_LANGUAGES.contains(request.language())) {
            throw new ResponseStatusException(org.springframework.http.HttpStatus.BAD_REQUEST, "Unsupported language");
        }

        User user = resolveCurrentUser();
        user.setPreferredLanguage(request.language());
        userRepository.save(user);

        return ResponseEntity.ok(new LanguageResponseDTO(user.getPreferredLanguage()));
    }

    private User resolveCurrentUser() {
        String email = SecurityUtils.getCurrentUserEmail();
        return userRepository.findByEmail(email)
                .orElseThrow(() -> new ResponseStatusException(org.springframework.http.HttpStatus.UNAUTHORIZED, "User not found"));
    }

    public record LanguageResponseDTO(String language) {}
    public record UpdateLanguageRequestDTO(String language) {}
}
