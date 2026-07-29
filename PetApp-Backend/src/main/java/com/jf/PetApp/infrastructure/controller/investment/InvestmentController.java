package com.jf.PetApp.infrastructure.controller.investment;

import com.jf.PetApp.application.investment.usecase.ConfigureInvestmentsUseCase;
import com.jf.PetApp.application.investment.usecase.GetPortfolioAllocationUseCase;
import com.jf.PetApp.application.investment.usecase.GetPortfolioHistoryUseCase;
import com.jf.PetApp.application.investment.usecase.GetPortfolioHoldingsUseCase;
import com.jf.PetApp.application.investment.usecase.GetPortfolioSummaryUseCase;
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
import com.jf.PetApp.application.investment.dto.InvestmentLotDTO;
import com.jf.PetApp.application.investment.dto.PortfolioSummaryDTO;
import com.jf.PetApp.application.investment.dto.AllocationSliceDTO;
import com.jf.PetApp.application.investment.dto.PortfolioHistoryPointDTO;
import java.util.Optional;
import java.util.List;

@RestController
@RequestMapping("/api/investments")
public class InvestmentController {

    private final ConfigureInvestmentsUseCase configureInvestmentsUseCase;
    private final ExternalInvestmentApiPort externalInvestmentApiPort;
    private final GetPortfolioHoldingsUseCase getPortfolioHoldingsUseCase;
    private final GetPortfolioSummaryUseCase getPortfolioSummaryUseCase;
    private final GetPortfolioAllocationUseCase getPortfolioAllocationUseCase;
    private final GetPortfolioHistoryUseCase getPortfolioHistoryUseCase;

    public InvestmentController(ConfigureInvestmentsUseCase configureInvestmentsUseCase,
                                 ExternalInvestmentApiPort externalInvestmentApiPort,
                                 GetPortfolioHoldingsUseCase getPortfolioHoldingsUseCase,
                                 GetPortfolioSummaryUseCase getPortfolioSummaryUseCase,
                                 GetPortfolioAllocationUseCase getPortfolioAllocationUseCase,
                                 GetPortfolioHistoryUseCase getPortfolioHistoryUseCase) {
        this.configureInvestmentsUseCase = configureInvestmentsUseCase;
        this.externalInvestmentApiPort = externalInvestmentApiPort;
        this.getPortfolioHoldingsUseCase = getPortfolioHoldingsUseCase;
        this.getPortfolioSummaryUseCase = getPortfolioSummaryUseCase;
        this.getPortfolioAllocationUseCase = getPortfolioAllocationUseCase;
        this.getPortfolioHistoryUseCase = getPortfolioHistoryUseCase;
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

    @GetMapping
    public ResponseEntity<List<InvestmentLotDTO>> getHoldings() {
        String email = com.jf.PetApp.core.security.SecurityUtils.getCurrentUserEmail();
        return ResponseEntity.ok(getPortfolioHoldingsUseCase.execute(email));
    }

    @GetMapping("/summary")
    public ResponseEntity<PortfolioSummaryDTO> getSummary() {
        String email = com.jf.PetApp.core.security.SecurityUtils.getCurrentUserEmail();
        return ResponseEntity.ok(getPortfolioSummaryUseCase.execute(email));
    }

    @GetMapping("/allocation")
    public ResponseEntity<List<AllocationSliceDTO>> getAllocation() {
        String email = com.jf.PetApp.core.security.SecurityUtils.getCurrentUserEmail();
        return ResponseEntity.ok(getPortfolioAllocationUseCase.execute(email));
    }

    @GetMapping("/history")
    public ResponseEntity<List<PortfolioHistoryPointDTO>> getHistory(
            @RequestParam(required = false, defaultValue = "ALL") String range) {
        String email = com.jf.PetApp.core.security.SecurityUtils.getCurrentUserEmail();
        return ResponseEntity.ok(getPortfolioHistoryUseCase.execute(email, range));
    }
}
