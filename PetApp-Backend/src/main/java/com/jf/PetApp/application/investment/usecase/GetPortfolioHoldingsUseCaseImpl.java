package com.jf.PetApp.application.investment.usecase;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;

import com.jf.PetApp.application.investment.dto.AssetQuoteResponse;
import com.jf.PetApp.application.investment.dto.InvestmentLotDTO;
import com.jf.PetApp.application.investment.port.ExternalInvestmentApiPort;
import com.jf.PetApp.infrastructure.entity.InvestmentJpaEntity;
import com.jf.PetApp.infrastructure.repository.InvestmentRepository;

@Service
public class GetPortfolioHoldingsUseCaseImpl implements GetPortfolioHoldingsUseCase {

    private final InvestmentRepository investmentRepository;
    private final ExternalInvestmentApiPort externalInvestmentApiPort;

    public GetPortfolioHoldingsUseCaseImpl(InvestmentRepository investmentRepository,
                                            ExternalInvestmentApiPort externalInvestmentApiPort) {
        this.investmentRepository = investmentRepository;
        this.externalInvestmentApiPort = externalInvestmentApiPort;
    }

    @Override
    public List<InvestmentLotDTO> execute(String email) {
        List<InvestmentJpaEntity> lots = investmentRepository.findByUser_Email(email);

        Map<String, Double> priceCache = new HashMap<>();
        for (InvestmentJpaEntity lot : lots) {
            priceCache.computeIfAbsent(lot.getName(), ticker -> fetchCurrentPrice(ticker, lot.getPurchasePrice()));
        }

        return lots.stream().map(lot -> {
            Double currentPrice = priceCache.get(lot.getName());
            Double investedValue = lot.getQuantity() * lot.getPurchasePrice();
            Double currentValue = lot.getQuantity() * currentPrice;
            return new InvestmentLotDTO(
                    lot.getId(),
                    lot.getName(),
                    lot.getType(),
                    lot.getQuantity(),
                    lot.getPurchasePrice(),
                    lot.getPurchaseDate(),
                    currentPrice,
                    investedValue,
                    currentValue
            );
        }).collect(Collectors.toList());
    }

    private Double fetchCurrentPrice(String ticker, Double fallbackPrice) {
        try {
            return externalInvestmentApiPort.getQuote(ticker)
                    .map(AssetQuoteResponse::regularMarketPrice)
                    .filter(price -> price != null)
                    .orElse(fallbackPrice);
        } catch (Exception e) {
            System.err.println("WARN: Failed to fetch quote for ticker " + ticker + ", falling back to purchase price. Cause: " + e.getMessage());
            return fallbackPrice;
        }
    }
}
