package com.jf.PetApp.core.domain;

import com.jf.PetApp.core.domain.enums.InvestmentType;
import java.time.LocalDate;

public record Investment(String id, String userEmail, String name, Double quantity, Double purchasePrice, LocalDate purchaseDate, InvestmentType type) {
}
