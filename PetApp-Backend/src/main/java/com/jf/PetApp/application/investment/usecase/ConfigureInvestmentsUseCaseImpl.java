package com.jf.PetApp.application.investment.usecase;

import java.util.List;
import java.util.stream.Collectors;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.jf.PetApp.core.domain.enums.InvestmentType;
import com.jf.PetApp.infrastructure.entity.InvestmentJpaEntity;
import com.jf.PetApp.infrastructure.entity.UserJpaEntity;
import com.jf.PetApp.infrastructure.repository.InvestmentRepository;
import com.jf.PetApp.infrastructure.repository.user.SpringUserJpaRepository;

@Service
public class ConfigureInvestmentsUseCaseImpl implements ConfigureInvestmentsUseCase {

    private final InvestmentRepository investmentRepository;
    private final SpringUserJpaRepository userRepository;

    public ConfigureInvestmentsUseCaseImpl(InvestmentRepository investmentRepository, SpringUserJpaRepository userRepository) {
        this.investmentRepository = investmentRepository;
        this.userRepository = userRepository;
    }

    @Override
    @Transactional
    public void execute(String email, List<InvestmentType> types) {
        UserJpaEntity user = userRepository.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("User not found for email: " + email));

        investmentRepository.deleteByUserEmail(email);

        List<InvestmentJpaEntity> newEntities = types.stream().map(type -> {
            InvestmentJpaEntity entity = new InvestmentJpaEntity();
            entity.setUser(user);
            entity.setType(type);
            return entity;
        }).collect(Collectors.toList());

        investmentRepository.saveAll(newEntities);
    }
}
