package com.jf.PetApp.core.domain;

import com.jf.PetApp.core.domain.enums.InvestmentType;

public record Investment(String id, String userEmail, InvestmentType type) {
}
