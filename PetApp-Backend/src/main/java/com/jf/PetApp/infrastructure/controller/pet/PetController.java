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
        String email = com.jf.PetApp.core.security.SecurityUtils.getCurrentUserEmail();
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
        String email = com.jf.PetApp.core.security.SecurityUtils.getCurrentUserEmail();
        boolean hasPet = getPetStatusUseCase.execute(email);
        return ResponseEntity.ok(new PetStatusResponseDTO(hasPet));
    }

    public record ConfigurePetRequestDTO(String specie) {}
    public record PetStatusResponseDTO(boolean hasPet) {}
}
