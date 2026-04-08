package com.jf.PetApp.application.investment.usecase;

import com.jf.PetApp.core.domain.User;
import com.jf.PetApp.core.domain.enums.InvestmentType;
import com.jf.PetApp.infrastructure.entity.UserJpaEntity;
import com.jf.PetApp.infrastructure.repository.InvestmentRepository;
import com.jf.PetApp.infrastructure.repository.UserRepository;
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
    private UserRepository userRepository;

    @InjectMocks
    private ConfigureInvestmentsUseCaseImpl configureInvestmentsUseCase;

    @BeforeEach
    void setUp() {
        MockitoAnnotations.openMocks(this);
    }

    @Test
    void execute_WhenUserExists_ShouldSaveInvestments() {
        String email = "investor@test.com";
        UserJpaEntity user = new UserJpaEntity();
        user.setEmail(email);

        when(userRepository.findByEmail(email)).thenReturn(Optional.of(user.toDomain()));

        configureInvestmentsUseCase.execute(email, List.of(InvestmentType.STOCKS, InvestmentType.CRYPTO));

        verify(investmentRepository, times(1)).deleteByUserEmail(email);
        verify(investmentRepository, times(2)).save(any());
    }

    @Test
    void execute_WhenUserDoesNotExist_ShouldThrowException() {
        String email = "missing@test.com";

        when(userRepository.findByEmail(email)).thenReturn(Optional.empty());

        assertThrows(IllegalArgumentException.class, () -> 
            configureInvestmentsUseCase.execute(email, List.of(InvestmentType.STOCKS)));
            
        verify(investmentRepository, never()).save(any());
    }
}
