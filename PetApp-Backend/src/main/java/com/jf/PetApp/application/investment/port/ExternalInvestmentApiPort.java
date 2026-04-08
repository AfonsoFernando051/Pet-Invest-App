package com.jf.PetApp.application.investment.port;

import com.jf.PetApp.application.investment.dto.AssetQuoteResponse;
import java.util.Optional;
import java.util.List;

public interface ExternalInvestmentApiPort {
    Optional<AssetQuoteResponse> getQuote(String ticker);
    List<AssetQuoteResponse> searchQuotes(String query);
}
