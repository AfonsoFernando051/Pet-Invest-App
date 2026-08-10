package com.jf.PetApp.application.investment.dto;

import java.util.List;

/**
 * Rich asset details response combining market data from the financial
 * data provider with the authenticated user's position. Every field is
 * nullable — the UI must handle absent data gracefully (show "Data
 * unavailable") rather than expecting every field to be populated.
 *
 * <p>This DTO intentionally does NOT invent, estimate or hallucinate any
 * financial data. A {@code null} field means "the provider did not return
 * this value" — not "zero" or "not applicable".</p>
 */
public record AssetDetailsResponseDTO(
    // ── Identity ──────────────────────────────────────────────
    String ticker,
    String shortName,
    String longName,
    String assetType,            // "stock", "fii", "etf", "bdr", "unknown"
    String sector,
    String industry,
    String logoUrl,

    // ── Price ─────────────────────────────────────────────────
    Double currentPrice,
    Double previousClose,
    Double dailyChange,
    Double dailyChangePercent,
    String currency,

    // ── Valuation (stocks & FIIs) ─────────────────────────────
    Double marketCap,
    Double priceToEarnings,      // P/E (P/L)
    Double priceToBook,          // P/VP
    Double evToEbitda,           // EV/EBITDA
    Double dividendYield,

    // ── Profitability (stocks) ────────────────────────────────
    Double returnOnEquity,       // ROE
    Double returnOnAssets,       // ROA
    Double netMargin,
    Double operatingMargin,

    // ── Financial health ──────────────────────────────────────
    Double netDebt,
    Double debtToEquity,
    Double totalCash,
    Double totalRevenue,
    Double ebitda,

    // ── FII-specific ──────────────────────────────────────────
    Double netAssetValue,        // Valor patrimonial por cota
    Double pvp,                  // P/VP (often returned separately for FIIs)

    // ── 52-week range ─────────────────────────────────────────
    Double fiftyTwoWeekHigh,
    Double fiftyTwoWeekLow,

    // ── Volume ────────────────────────────────────────────────
    Long averageVolume,
    Long regularMarketVolume,

    // ── User position (null if user doesn't own this asset) ──
    UserPositionDTO userPosition,

    // ── Dividends (most recent, capped) ──────────────────────
    List<DividendRadarEntryDTO> recentDividends,

    // ── Meta ──────────────────────────────────────────────────
    String dataSource,
    String lastUpdated,
    String dataStatus            // "FRESH", "CACHED", "DELAYED", "PARTIAL"
) {
}
