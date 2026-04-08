package com.jf.PetApp.application.investment.usecase;

import java.util.List;
import com.jf.PetApp.infrastructure.controller.investment.dto.AssetRegistrationDto;

public interface ConfigureInvestmentsUseCase {
    void execute(String email, List<AssetRegistrationDto> investments);
}
