package com.jf.PetApp.infrastructure.controller.investment.dto;

import com.jf.PetApp.core.domain.enums.InvestmentType;
import java.time.LocalDate;

public record AssetRegistrationDto(
        String name,
        Double quantity,
        Double purchasePrice,
        LocalDate purchaseDate,
        InvestmentType type
) {
}
