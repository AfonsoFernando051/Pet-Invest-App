package com.jf.PetApp.infrastructure.persistence.user;

import org.springframework.data.jpa.repository.JpaRepository;

import com.jf.PetApp.domain.User;

import java.util.Optional;

public interface SpringUserJpaRepository
        extends JpaRepository<UserJpaEntity, Integer> {

    Optional<UserJpaEntity> findByEmail(String email);

	void save(User user);
}
