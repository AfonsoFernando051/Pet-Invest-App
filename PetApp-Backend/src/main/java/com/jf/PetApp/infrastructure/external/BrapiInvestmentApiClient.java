package com.jf.PetApp.infrastructure.external;

import com.jf.PetApp.application.investment.dto.AssetQuoteResponse;
import com.jf.PetApp.application.investment.dto.DividendDTO;
import com.jf.PetApp.application.investment.port.ExternalInvestmentApiPort;
import com.jf.PetApp.core.domain.enums.DividendType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.client.HttpClientErrorException;
import java.time.Instant;
import java.time.LocalDate;
import java.time.ZoneOffset;
import java.time.format.DateTimeParseException;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import java.util.Optional;

@Service
public class BrapiInvestmentApiClient implements ExternalInvestmentApiPort {

    private static final Logger log = LoggerFactory.getLogger(BrapiInvestmentApiClient.class);

    private final RestTemplate restTemplate;
    
    @Value("${api.brapi.token:}")
    private String token;

    public BrapiInvestmentApiClient() {
        this.restTemplate = new RestTemplate();
    }

    @Override
    public Optional<AssetQuoteResponse> getQuote(String ticker) {
        if (token == null || token.isBlank()) {
            log.warn("api.brapi.token is not configured; returning mock data for {}", ticker);
            // Provide a mock response if no token is configured yet.
            return Optional.of(new AssetQuoteResponse(ticker.toUpperCase(), "Simulated " + ticker.toUpperCase(), 50.0, "BRL"));
        }

        try {
            String url = String.format("https://brapi.dev/api/quote/%s?token=%s", ticker, token);
            Map<String, Object> response = restTemplate.getForObject(url, Map.class);
            
            if (response != null && response.containsKey("results")) {
                List<Map<String, Object>> results = (List<Map<String, Object>>) response.get("results");
                if (results != null && !results.isEmpty()) {
                    Map<String, Object> data = results.get(0);
                    String symbol = (String) data.getOrDefault("symbol", ticker);
                    String shortName = (String) data.getOrDefault("shortName", "");
                    
                    Object priceObj = data.get("regularMarketPrice");
                    Double price = null;
                    if (priceObj instanceof Number) {
                        price = ((Number) priceObj).doubleValue();
                    }
                    
                    String currency = (String) data.getOrDefault("currency", "BRL");

                    Object changePercentObj = data.get("regularMarketChangePercent");
                    Double changePercent = 0.0;
                    if (changePercentObj instanceof Number) {
                        changePercent = ((Number) changePercentObj).doubleValue();
                    }

                    return Optional.of(new AssetQuoteResponse(symbol, shortName, price, currency, changePercent));
                }
            }
            return Optional.empty();
        } catch (HttpClientErrorException e) {
            log.warn("Brapi quote request failed for {}: HTTP {}", ticker, e.getStatusCode());
            return Optional.empty();
        } catch (Exception e) {
            // Don't log e.getMessage()/stack trace here: connectivity exceptions from
            // RestTemplate commonly embed the full request URL, which includes the token.
            log.warn("Brapi quote request failed for {}: {}", ticker, e.getClass().getSimpleName());
            return Optional.empty();
        }
    }

    @Override
    public List<AssetQuoteResponse> searchQuotes(String query) {
        try {
            // we can use search without a token
            String url = String.format("https://brapi.dev/api/quote/list?search=%s", query);
            Map<String, Object> response = restTemplate.getForObject(url, Map.class);
            
            List<AssetQuoteResponse> resultList = new ArrayList<>();
            if (response != null && response.containsKey("stocks")) {
                List<Map<String, Object>> stocks = (List<Map<String, Object>>) response.get("stocks");
                if (stocks != null) {
                    for (Map<String, Object> stock : stocks) {
                        String symbol = (String) stock.getOrDefault("stock", "");
                        String name = (String) stock.getOrDefault("name", "");
                        
                        Object priceObj = stock.get("close");
                        Double price = null;
                        if (priceObj instanceof Number) {
                            price = ((Number) priceObj).doubleValue();
                        }
                        
                        resultList.add(new AssetQuoteResponse(symbol, name, price, "BRL"));
                    }
                }
            }
            return resultList;
        } catch (Exception e) {
            // No token in this URL (search doesn't require one), so the message is safe to log.
            log.warn("Brapi search request failed for query '{}': {}", query, e.getMessage());
            return new ArrayList<>();
        }
    }

    @Override
    @SuppressWarnings("unchecked")
    public List<DividendDTO> getDividends(String ticker) {
        List<DividendDTO> result = new ArrayList<>();
        try {
            String url = String.format("https://brapi.dev/api/v2/stocks/dividends?symbols=%s", ticker.toUpperCase());
            if (token != null && !token.isBlank()) {
                url += "&token=" + token;
            }
            Map<String, Object> response = restTemplate.getForObject(url, Map.class);
            if (response == null || !response.containsKey("results")) {
                return result;
            }

            List<Map<String, Object>> results = (List<Map<String, Object>>) response.get("results");
            if (results == null || results.isEmpty()) {
                return result;
            }

            Object dataObj = results.get(0).get("data");
            if (!(dataObj instanceof Map)) {
                return result;
            }
            Map<String, Object> data = (Map<String, Object>) dataObj;

            Object cashDividendsObj = data.get("cashDividends");
            if (!(cashDividendsObj instanceof List)) {
                return result;
            }
            List<Map<String, Object>> cashDividends = (List<Map<String, Object>>) cashDividendsObj;

            for (Map<String, Object> entry : cashDividends) {
                Double rate = toDouble(entry.get("rate"));
                // Never report a payment we can't confirm a value for.
                if (rate == null) continue;

                String rawLabel = (String) entry.get("label");
                result.add(new DividendDTO(
                        ticker.toUpperCase(),
                        DividendType.fromRawLabel(rawLabel),
                        rawLabel,
                        rate,
                        toLocalDate(entry.get("lastDatePrior")),
                        toLocalDate(entry.get("paymentDate")),
                        toLocalDate(entry.get("approvedOn"))
                ));
            }
            return result;
        } catch (Exception e) {
            // This URL may include the token; log the exception type only, never its message.
            log.warn("Failed to fetch dividends from Brapi for {}: {}", ticker, e.getClass().getSimpleName());
            return new ArrayList<>();
        }
    }

    private static Double toDouble(Object value) {
        return value instanceof Number ? ((Number) value).doubleValue() : null;
    }

    /**
     * Brapi encodes each date as Brazilian local midnight serialized in UTC
     * (e.g. {@code 2026-09-21T03:00:00.000Z} = 2026-09-21 00:00 America/Sao_Paulo),
     * so reading the UTC calendar date back out yields the correct local date.
     */
    private static LocalDate toLocalDate(Object value) {
        if (!(value instanceof String) || ((String) value).isBlank()) return null;
        try {
            return Instant.parse((String) value).atZone(ZoneOffset.UTC).toLocalDate();
        } catch (DateTimeParseException e) {
            return null;
        }
    }

    @Override
    @SuppressWarnings("unchecked")
    public Optional<Map<String, Object>> getEnrichedQuote(String ticker) {
        if (token == null || token.isBlank()) {
            log.warn("api.brapi.token is not configured; cannot fetch enriched quote for {}", ticker);
            return Optional.empty();
        }

        try {
            // Request all available modules from Brapi for maximum data coverage.
            // The summaryProfile module provides sector, industry, description, etc.
            String url = String.format(
                "https://brapi.dev/api/quote/%s?token=%s&modules=summaryProfile",
                ticker, token
            );
            Map<String, Object> response = restTemplate.getForObject(url, Map.class);

            if (response != null && response.containsKey("results")) {
                List<Map<String, Object>> results = (List<Map<String, Object>>) response.get("results");
                if (results != null && !results.isEmpty()) {
                    return Optional.of(results.get(0));
                }
            }
            return Optional.empty();
        } catch (HttpClientErrorException e) {
            log.warn("Brapi enriched quote request failed for {}: HTTP {}", ticker, e.getStatusCode());
            return Optional.empty();
        } catch (Exception e) {
            // Don't log e.getMessage(): connectivity exceptions may embed the token in the URL.
            log.warn("Brapi enriched quote request failed for {}: {}", ticker, e.getClass().getSimpleName());
            return Optional.empty();
        }
    }
}

