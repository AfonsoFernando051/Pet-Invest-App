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
        String email = com.jf.PetApp.core.security.SecurityUtils.getCurrentUserEmail();
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

    public record ConfigureInvestmentsRequestDTO(List<String> investments) {}
}
