package com.jf.PetApp.infrastructure.controller.investment;

import com.jf.PetApp.application.investment.usecase.ConfigureInvestmentsUseCase;
import com.jf.PetApp.core.domain.User;
import com.jf.PetApp.core.domain.enums.InvestmentType;

import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/investments")
public class InvestmentController {

    private final ConfigureInvestmentsUseCase configureInvestmentsUseCase;

    public InvestmentController(ConfigureInvestmentsUseCase configureInvestmentsUseCase) {
        this.configureInvestmentsUseCase = configureInvestmentsUseCase;
    }

    @PostMapping("/configure")
    public ResponseEntity<Void> configureInvestments(@RequestBody ConfigureInvestmentsRequestDTO request) {
        String email = resolveCurrentUserEmail();
        try {
            List<InvestmentType> types = request.investments().stream()
                .map(inv -> InvestmentType.valueOf(inv.toUpperCase()))
                .collect(Collectors.toList());
                
            configureInvestmentsUseCase.execute(email, types);
            return ResponseEntity.ok().build();
        } catch (IllegalArgumentException e) {
            throw new ResponseStatusException(org.springframework.http.HttpStatus.BAD_REQUEST, "Invalid investment type");
        }
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

    public record ConfigureInvestmentsRequestDTO(List<String> investments) {}
}
