package com.jf.PetApp.infrastructure.controller.pet;

import com.jf.PetApp.application.pet.usecase.ConfigurePetUseCase;
import com.jf.PetApp.application.pet.usecase.GetPetStatusUseCase;
import com.jf.PetApp.core.domain.User;
import com.jf.PetApp.core.domain.enums.PetSpecieEnum;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api/pets")
public class PetController {

    private final ConfigurePetUseCase configurePetUseCase;
    private final GetPetStatusUseCase getPetStatusUseCase;

    public PetController(ConfigurePetUseCase configurePetUseCase, GetPetStatusUseCase getPetStatusUseCase) {
        this.configurePetUseCase = configurePetUseCase;
        this.getPetStatusUseCase = getPetStatusUseCase;
    }

    @PostMapping("/configure")
    public ResponseEntity<Void> configurePet(@RequestBody ConfigurePetRequestDTO request) {
        String email = resolveCurrentUserEmail();
        try {
            PetSpecieEnum specie = PetSpecieEnum.valueOf(request.specie().toUpperCase());
            configurePetUseCase.execute(email, specie);
            return ResponseEntity.ok().build();
        } catch (IllegalArgumentException e) {
            throw new ResponseStatusException(org.springframework.http.HttpStatus.BAD_REQUEST, "Invalid specie");
        }
    }

    @GetMapping("/status")
    public ResponseEntity<PetStatusResponseDTO> getStatus() {
        String email = resolveCurrentUserEmail();
        boolean hasPet = getPetStatusUseCase.execute(email);
        return ResponseEntity.ok(new PetStatusResponseDTO(hasPet));
    }

    private String resolveCurrentUserEmail() {
        Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (authentication == null || !authentication.isAuthenticated()) {
            throw new ResponseStatusException(org.springframework.http.HttpStatus.UNAUTHORIZED, "Not authenticated");
        }

        Object principal = authentication.getPrincipal();
        if (principal instanceof User domainUser) {
            return domainUser.getEmail();
        }

        if (principal instanceof UserDetails userDetails) {
            return userDetails.getUsername();
        } else if (principal instanceof String principalString) {
            return principalString;
        }

        throw new ResponseStatusException(org.springframework.http.HttpStatus.UNAUTHORIZED, "User identity not available");
    }

    public record ConfigurePetRequestDTO(String specie) {}
    public record PetStatusResponseDTO(boolean hasPet) {}
}
