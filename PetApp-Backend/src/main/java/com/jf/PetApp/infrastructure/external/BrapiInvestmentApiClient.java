package com.jf.PetApp.infrastructure.external;

import com.jf.PetApp.application.investment.dto.AssetQuoteResponse;
import com.jf.PetApp.application.investment.port.ExternalInvestmentApiPort;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.client.HttpClientErrorException;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
public class BrapiInvestmentApiClient implements ExternalInvestmentApiPort {

    private final RestTemplate restTemplate;
    
    @Value("${api.brapi.token:}")
    private String token;

    public BrapiInvestmentApiClient() {
        this.restTemplate = new RestTemplate();
    }

    @Override
    public Optional<AssetQuoteResponse> getQuote(String ticker) {
        if (token == null || token.isBlank()) {
            System.err.println("WARN: api.brapi.token is missing in application.properties. Providing mock data for " + ticker);
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
                    
                    return Optional.of(new AssetQuoteResponse(symbol, shortName, price, currency));
                }
            }
            return Optional.empty();
        } catch (HttpClientErrorException e) {
            System.err.println("Error fetching quote from Brapi: " + e.getStatusCode());
            return Optional.empty();
        } catch (Exception e) {
            e.printStackTrace();
            return Optional.empty();
        }
    }
}
