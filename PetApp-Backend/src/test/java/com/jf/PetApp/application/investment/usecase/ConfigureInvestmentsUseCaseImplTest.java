package com.jf.PetApp.application.investment.usecase;

import com.jf.PetApp.core.domain.User;
import com.jf.PetApp.core.domain.enums.InvestmentType;
import com.jf.PetApp.infrastructure.controller.investment.dto.AssetRegistrationDto;
import com.jf.PetApp.infrastructure.entity.UserJpaEntity;
import com.jf.PetApp.infrastructure.repository.InvestmentRepository;
import com.jf.PetApp.infrastructure.repository.user.SpringUserJpaRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;

import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

public class ConfigureInvestmentsUseCaseImplTest {

    @Mock
    private InvestmentRepository investmentRepository;

    @Mock
    private SpringUserJpaRepository userRepository;

    @InjectMocks
    private ConfigureInvestmentsUseCaseImpl configureInvestmentsUseCase;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    void execute_WhenUserExists_ShouldSaveInvestments() {
        String email = "investor@test.com";
        UserJpaEntity mockUser = mock(UserJpaEntity.class);

        when(userRepository.findByEmail(email)).thenReturn(Optional.of(mockUser));

        AssetRegistrationDto asset1 = new AssetRegistrationDto("PETR4", 100.0, 35.5, java.time.LocalDate.now(), InvestmentType.STOCKS);
        AssetRegistrationDto asset2 = new AssetRegistrationDto("BTC", 0.5, 300000.0, java.time.LocalDate.now(), InvestmentType.CRYPTO);

        configureInvestmentsUseCase.execute(email, List.of(asset1, asset2));

        verify(investmentRepository, times(1)).deleteByUserEmail(email);
        verify(investmentRepository, times(1)).saveAll(any());
    }

    @Test
    void execute_WhenUserDoesNotExist_ShouldThrowException() {
        String email = "missing@test.com";

        when(userRepository.findByEmail(email)).thenReturn(Optional.empty());

        AssetRegistrationDto asset1 = new AssetRegistrationDto("PETR4", 100.0, 35.5, java.time.LocalDate.now(), InvestmentType.STOCKS);

        assertThrows(IllegalArgumentException.class, () -> 
            configureInvestmentsUseCase.execute(email, List.of(asset1)));
            
        verify(investmentRepository, never()).saveAll(any());
    }
}
