package com.jf.PetApp.infrastructure.persistence.user;

import org.springframework.data.jpa.repository.JpaRepository;
import java.util.Optional;

interface SpringUserJpaRepository
        extends JpaRepository<UserJpaEntity, Integer> {

    Optional<UserJpaEntity> findByEmail(String email);
}
