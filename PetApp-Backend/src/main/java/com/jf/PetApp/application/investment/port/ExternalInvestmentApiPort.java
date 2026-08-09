package com.jf.PetApp.application.investment.port;

import com.jf.PetApp.application.investment.dto.AssetQuoteResponse;
import com.jf.PetApp.application.investment.dto.DividendDTO;
import java.util.Optional;
import java.util.List;

public interface ExternalInvestmentApiPort {
    Optional<AssetQuoteResponse> getQuote(String ticker);
    List<AssetQuoteResponse> searchQuotes(String query);

    /**
     * Confirmed cash-dividend/JCP/yield history and announcements for a
     * ticker. Returns an empty list when the provider has nothing to report
     * (unknown ticker, no corporate actions, provider error) — implementations
     * must never fabricate an entry to fill this list.
     */
    List<DividendDTO> getDividends(String ticker);
}
