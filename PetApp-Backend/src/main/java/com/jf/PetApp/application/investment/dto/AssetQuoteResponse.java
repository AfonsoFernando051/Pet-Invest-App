package com.jf.PetApp.application.investment.dto;

public record AssetQuoteResponse(
    String symbol,
    String shortName,
    Double regularMarketPrice,
    String currency
) {
}
