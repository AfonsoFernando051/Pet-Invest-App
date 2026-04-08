package com.jf.PetApp.application.investment.port;

import com.jf.PetApp.application.investment.dto.AssetQuoteResponse;
import java.util.Optional;

public interface ExternalInvestmentApiPort {
    Optional<AssetQuoteResponse> getQuote(String ticker);
}
