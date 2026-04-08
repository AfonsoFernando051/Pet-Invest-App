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

import com.jf.PetApp.infrastructure.controller.investment.dto.AssetRegistrationDto;
import com.jf.PetApp.application.investment.port.ExternalInvestmentApiPort;
import com.jf.PetApp.application.investment.dto.AssetQuoteResponse;
import java.util.Optional;
import java.util.List;

@RestController
@RequestMapping("/api/investments")
public class InvestmentController {

    private final ConfigureInvestmentsUseCase configureInvestmentsUseCase;
    private final ExternalInvestmentApiPort externalInvestmentApiPort;

    public InvestmentController(ConfigureInvestmentsUseCase configureInvestmentsUseCase, ExternalInvestmentApiPort externalInvestmentApiPort) {
        this.configureInvestmentsUseCase = configureInvestmentsUseCase;
        this.externalInvestmentApiPort = externalInvestmentApiPort;
    }

    @PostMapping("/configure")
    public ResponseEntity<Void> configureInvestments(@RequestBody List<AssetRegistrationDto> request) {
        String email = com.jf.PetApp.core.security.SecurityUtils.getCurrentUserEmail();
        try {
            configureInvestmentsUseCase.execute(email, request);
            return ResponseEntity.ok().build();
        } catch (IllegalArgumentException e) {
            throw new ResponseStatusException(org.springframework.http.HttpStatus.BAD_REQUEST, "Invalid investment data");
        }
    }

    @GetMapping("/quote/{ticker}")
    public ResponseEntity<AssetQuoteResponse> getQuote(@PathVariable String ticker) {
        Optional<AssetQuoteResponse> quoteOpt = externalInvestmentApiPort.getQuote(ticker);
        return quoteOpt.map(ResponseEntity::ok)
                .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @GetMapping("/search")
    public ResponseEntity<List<AssetQuoteResponse>> searchQuotes(@RequestParam String query) {
        return ResponseEntity.ok(externalInvestmentApiPort.searchQuotes(query));
    }
}
