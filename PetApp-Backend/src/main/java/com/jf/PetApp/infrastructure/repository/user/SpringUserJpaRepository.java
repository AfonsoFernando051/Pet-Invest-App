package com.jf.PetApp.infrastructure.repository.user;

import com.jf.PetApp.core.domain.User;
import com.jf.PetApp.infrastructure.entity.UserJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface SpringUserJpaRepository
        extends JpaRepository<UserJpaEntity, Integer> {

    Optional<UserJpaEntity> findByEmail(String email);

    void save(User user);
}
