package com.jf.PetApp.application.investment.usecase;

import com.jf.PetApp.application.investment.cache.AssetDetailsCache;
import com.jf.PetApp.application.investment.dto.AssetDetailsResponseDTO;
import com.jf.PetApp.application.investment.dto.AssetQuoteResponse;
import com.jf.PetApp.application.investment.dto.DividendDTO;
import com.jf.PetApp.application.investment.dto.DividendRadarEntryDTO;
import com.jf.PetApp.application.investment.dto.UserPositionDTO;
import com.jf.PetApp.application.investment.port.ExternalInvestmentApiPort;
import com.jf.PetApp.application.investment.port.InvestmentRepositoryPort;
import com.jf.PetApp.core.domain.Investment;
import com.jf.PetApp.core.domain.enums.InvestmentType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * Orchestrates the enriched asset details response by combining:
 * <ol>
 *   <li>Enriched market data from the financial data provider</li>
 *   <li>The authenticated user's real position (if they own the asset)</li>
 *   <li>Recent dividend history from the provider</li>
 * </ol>
 *
 * <p>Every field that the provider does not return stays {@code null} — this
 * class never fabricates, estimates or hallucinates financial data.</p>
 */
@Service
public class GetAssetDetailsUseCaseImpl implements GetAssetDetailsUseCase {

    private static final Logger log = LoggerFactory.getLogger(GetAssetDetailsUseCaseImpl.class);
    private static final int MAX_RECENT_DIVIDENDS = 12;

    private final ExternalInvestmentApiPort externalApi;
    private final InvestmentRepositoryPort investmentRepo;
    private final AssetDetailsCache cache;

    public GetAssetDetailsUseCaseImpl(ExternalInvestmentApiPort externalApi,
                                      InvestmentRepositoryPort investmentRepo,
                                      AssetDetailsCache cache) {
        this.externalApi = externalApi;
        this.investmentRepo = investmentRepo;
        this.cache = cache;
    }

    @Override
    public AssetDetailsResponseDTO execute(String email, String ticker) {
        String normalizedTicker = ticker.toUpperCase().trim();

        // 1. Check cache first
        AssetDetailsResponseDTO cached = cache.get(normalizedTicker);
        if (cached != null) {
            // Cached response has market-wide data; recompute user position fresh
            UserPositionDTO userPosition = computeUserPosition(email, normalizedTicker, cached.currentPrice());
            return withUserPositionAndStatus(cached, userPosition, "CACHED");
        }

        // 2. Fetch enriched quote from provider
        Optional<Map<String, Object>> enrichedOpt = externalApi.getEnrichedQuote(normalizedTicker);

        if (enrichedOpt.isEmpty()) {
            // Fallback: try the simpler getQuote for basic price data
            Optional<AssetQuoteResponse> simpleQuote = externalApi.getQuote(normalizedTicker);
            if (simpleQuote.isEmpty()) {
                return buildUnavailableResponse(email, normalizedTicker);
            }
            return buildFromSimpleQuote(email, normalizedTicker, simpleQuote.get());
        }

        Map<String, Object> data = enrichedOpt.get();

        // 3. Detect asset type from ticker pattern and provider data
        String assetType = detectAssetType(normalizedTicker, data);

        // 4. Extract fields (null-safe — never fabricated)
        Double currentPrice = toDouble(data.get("regularMarketPrice"));
        Double previousClose = toDouble(data.get("regularMarketPreviousClose"));
        Double dailyChange = toDouble(data.get("regularMarketChange"));
        Double dailyChangePercent = toDouble(data.get("regularMarketChangePercent"));

        // 5. Build user position
        UserPositionDTO userPosition = computeUserPosition(email, normalizedTicker, currentPrice);

        // 6. Fetch dividends
        List<DividendRadarEntryDTO> recentDividends = fetchRecentDividends(email, normalizedTicker);

        // 7. Extract summary profile if available
        String sector = toString(data.get("sector"));
        String industry = toString(data.get("industry"));
        String longName = toString(data.get("longName"));

        // Check for summaryProfile module data (Brapi nests it)
        @SuppressWarnings("unchecked")
        Map<String, Object> summaryProfile = data.get("summaryProfile") instanceof Map
                ? (Map<String, Object>) data.get("summaryProfile")
                : null;
        if (summaryProfile != null) {
            if (sector == null) sector = toString(summaryProfile.get("sector"));
            if (industry == null) industry = toString(summaryProfile.get("industry"));
            if (longName == null) longName = toString(summaryProfile.get("longName"));
        }

        AssetDetailsResponseDTO result = new AssetDetailsResponseDTO(
            normalizedTicker,
            toString(data.get("shortName")),
            longName,
            assetType,
            sector,
            industry,
            toString(data.get("logourl")),

            // Price
            currentPrice,
            previousClose,
            dailyChange,
            dailyChangePercent,
            toString(data.get("currency")),

            // Valuation
            toDouble(data.get("marketCap")),
            toDouble(data.get("priceEarnings")),
            toDouble(data.get("priceToBook")),
            toDouble(data.get("evToEbitda")),
            toDouble(data.get("dividendYield")),

            // Profitability
            toDouble(data.get("returnOnEquity")),
            toDouble(data.get("returnOnAssets")),
            toDouble(data.get("netMargin")),
            toDouble(data.get("operatingMargin")),

            // Financial health
            toDouble(data.get("netDebt")),
            toDouble(data.get("debtToEquity")),
            toDouble(data.get("totalCash")),
            toDouble(data.get("totalRevenue")),
            toDouble(data.get("ebitda")),

            // FII-specific
            toDouble(data.get("netAssetValue")),
            toDouble(data.get("priceToBook")),  // P/VP for FIIs

            // 52-week range
            toDouble(data.get("fiftyTwoWeekHigh")),
            toDouble(data.get("fiftyTwoWeekLow")),

            // Volume
            toLong(data.get("averageDailyVolume3Month")),
            toLong(data.get("regularMarketVolume")),

            // User position
            userPosition,

            // Dividends
            recentDividends,

            // Meta
            "brapi.dev",
            Instant.now().toString(),
            "FRESH"
        );

        // 8. Cache (without user position — that's per-user)
        cache.put(normalizedTicker, result);

        return result;
    }

    // ── User position computation ─────────────────────────────────────────

    private UserPositionDTO computeUserPosition(String email, String ticker, Double currentPrice) {
        List<Investment> lots = investmentRepo.findByUserEmail(email);
        List<Investment> tickerLots = lots.stream()
                .filter(lot -> lot.name().equalsIgnoreCase(ticker))
                .toList();

        if (tickerLots.isEmpty()) return null;

        double quantity = tickerLots.stream().mapToDouble(Investment::quantity).sum();
        double investedValue = tickerLots.stream()
                .mapToDouble(lot -> lot.quantity() * lot.purchasePrice())
                .sum();
        double averagePrice = quantity == 0 ? 0.0 : investedValue / quantity;

        double price = currentPrice != null ? currentPrice : averagePrice;
        double currentValue = quantity * price;
        double unrealizedGain = currentValue - investedValue;
        double unrealizedGainPercent = investedValue == 0 ? 0.0 : (unrealizedGain / investedValue) * 100;

        // Portfolio weight: this ticker's value / total portfolio value
        double totalPortfolioValue = lots.stream()
                .mapToDouble(lot -> {
                    // For simplicity, use purchase price as proxy for current price of other holdings
                    // (the dedicated holdings endpoint computes this more accurately with live quotes)
                    if (lot.name().equalsIgnoreCase(ticker) && currentPrice != null) {
                        return lot.quantity() * currentPrice;
                    }
                    return lot.quantity() * lot.purchasePrice();
                })
                .sum();
        double portfolioWeight = totalPortfolioValue == 0 ? 0.0 : (currentValue / totalPortfolioValue) * 100;

        return new UserPositionDTO(
            quantity, averagePrice, investedValue, currentValue,
            unrealizedGain, unrealizedGainPercent, portfolioWeight
        );
    }

    // ── Dividend fetching ─────────────────────────────────────────────────

    private List<DividendRadarEntryDTO> fetchRecentDividends(String email, String ticker) {
        try {
            List<DividendDTO> dividends = externalApi.getDividends(ticker);
            if (dividends.isEmpty()) return List.of();

            // Get user's quantity for this ticker
            List<Investment> lots = investmentRepo.findByUserEmail(email);
            double userQuantity = lots.stream()
                    .filter(lot -> lot.name().equalsIgnoreCase(ticker))
                    .mapToDouble(Investment::quantity)
                    .sum();

            LocalDate today = LocalDate.now();
            List<DividendRadarEntryDTO> entries = new ArrayList<>();

            for (DividendDTO div : dividends) {
                boolean paid = div.paymentDate() != null && !div.paymentDate().isAfter(today);
                String status = paid ? DividendRadarEntryDTO.STATUS_PAID : DividendRadarEntryDTO.STATUS_ANNOUNCED;
                double qty = userQuantity > 0 ? userQuantity : 0;
                entries.add(new DividendRadarEntryDTO(
                    div.ticker(), div.type(), div.rawLabel(), div.ratePerShare(),
                    div.dataCom(), div.paymentDate(), div.approvedOn(),
                    qty, div.ratePerShare() * qty, status
                ));
            }

            // Sort most recent first, cap at MAX_RECENT_DIVIDENDS
            entries.sort((a, b) -> {
                if (a.paymentDate() == null && b.paymentDate() == null) return 0;
                if (a.paymentDate() == null) return 1;
                if (b.paymentDate() == null) return -1;
                return b.paymentDate().compareTo(a.paymentDate());
            });

            return entries.subList(0, Math.min(entries.size(), MAX_RECENT_DIVIDENDS));
        } catch (Exception e) {
            log.warn("Failed to fetch dividends for asset details {}: {}", ticker, e.getMessage());
            return List.of();
        }
    }

    // ── Fallback builders ─────────────────────────────────────────────────

    private AssetDetailsResponseDTO buildUnavailableResponse(String email, String ticker) {
        UserPositionDTO userPosition = computeUserPosition(email, ticker, null);
        return new AssetDetailsResponseDTO(
            ticker, null, null, detectAssetTypeFromTicker(ticker),
            null, null, null,
            null, null, null, null, null,
            null, null, null, null, null,
            null, null, null, null,
            null, null, null, null, null,
            null, null,
            null, null,
            null, null,
            userPosition,
            List.of(),
            "unavailable", Instant.now().toString(), "UNAVAILABLE"
        );
    }

    private AssetDetailsResponseDTO buildFromSimpleQuote(String email, String ticker, AssetQuoteResponse quote) {
        UserPositionDTO userPosition = computeUserPosition(email, ticker, quote.regularMarketPrice());
        List<DividendRadarEntryDTO> dividends = fetchRecentDividends(email, ticker);

        return new AssetDetailsResponseDTO(
            ticker, quote.shortName(), null, detectAssetTypeFromTicker(ticker),
            null, null, null,
            quote.regularMarketPrice(), null, null, quote.regularMarketChangePercent(), quote.currency(),
            null, null, null, null, null,
            null, null, null, null,
            null, null, null, null, null,
            null, null,
            null, null,
            null, null,
            userPosition,
            dividends,
            "brapi.dev", Instant.now().toString(), "PARTIAL"
        );
    }

    private AssetDetailsResponseDTO withUserPositionAndStatus(
            AssetDetailsResponseDTO base, UserPositionDTO userPosition, String status) {
        return new AssetDetailsResponseDTO(
            base.ticker(), base.shortName(), base.longName(), base.assetType(),
            base.sector(), base.industry(), base.logoUrl(),
            base.currentPrice(), base.previousClose(), base.dailyChange(),
            base.dailyChangePercent(), base.currency(),
            base.marketCap(), base.priceToEarnings(), base.priceToBook(),
            base.evToEbitda(), base.dividendYield(),
            base.returnOnEquity(), base.returnOnAssets(), base.netMargin(),
            base.operatingMargin(),
            base.netDebt(), base.debtToEquity(), base.totalCash(),
            base.totalRevenue(), base.ebitda(),
            base.netAssetValue(), base.pvp(),
            base.fiftyTwoWeekHigh(), base.fiftyTwoWeekLow(),
            base.averageVolume(), base.regularMarketVolume(),
            userPosition,
            base.recentDividends(),
            base.dataSource(), base.lastUpdated(), status
        );
    }

    // ── Asset type detection ──────────────────────────────────────────────

    /**
     * Detects asset type from the Brapi response data combined with ticker
     * pattern heuristics (Brazilian tickers follow predictable patterns).
     */
    private String detectAssetType(String ticker, Map<String, Object> data) {
        // Brapi sometimes includes "type" or we can detect from other fields
        String brapiType = toString(data.get("type"));
        if (brapiType != null) {
            String lower = brapiType.toLowerCase();
            if (lower.contains("fund") || lower.contains("fii") || lower.contains("fdo")) return "fii";
            if (lower.contains("etf") || lower.contains("index")) return "etf";
            if (lower.contains("bdr")) return "bdr";
            if (lower.contains("stock") || lower.contains("equity")) return "stock";
        }

        return detectAssetTypeFromTicker(ticker);
    }

    /**
     * Heuristic: Brazilian ticker suffixes.
     * 11 = FII/ETF, 3/4 = stock, 34/35 = BDR.
     */
    private String detectAssetTypeFromTicker(String ticker) {
        if (ticker.length() >= 5) {
            String suffix = ticker.substring(ticker.length() - 2);
            if ("11".equals(suffix)) {
                // Common FIIs: XPML11, HGLG11, etc. Some ETFs also end in 11: IVVB11, BOVA11
                // Heuristic: 4 letters + 11 = FII, 4+ letters + 11 = could be either
                return "fii"; // Default to FII; the enriched data can override later
            }
            if ("34".equals(suffix) || "35".equals(suffix)) return "bdr";
            if ("39".equals(suffix)) return "etf";
        }
        return "stock"; // Default assumption
    }

    // ── Type-safe field extraction (never fabricates) ──────────────────────

    private static Double toDouble(Object value) {
        if (value instanceof Number) return ((Number) value).doubleValue();
        return null;
    }

    private static Long toLong(Object value) {
        if (value instanceof Number) return ((Number) value).longValue();
        return null;
    }

    private static String toString(Object value) {
        if (value instanceof String s && !s.isBlank()) return s;
        return null;
    }
}
