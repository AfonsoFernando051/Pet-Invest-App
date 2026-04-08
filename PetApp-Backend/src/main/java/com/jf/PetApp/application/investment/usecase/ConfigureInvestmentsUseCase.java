package com.jf.PetApp.application.investment.usecase;

import java.util.List;
import com.jf.PetApp.core.domain.enums.InvestmentType;

public interface ConfigureInvestmentsUseCase {
    void execute(String email, List<InvestmentType> investments);
}
