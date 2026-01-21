package com.jf.PetApp.infrastructure.persistence.user;

import java.util.Optional;

import org.springframework.stereotype.Repository;

import com.jf.PetApp.domain.User;
import com.jf.PetApp.domain.UserRepository;

@Repository
public class JpaUserRepository implements UserRepository {

    private final SpringUserJpaRepository jpa;

    public JpaUserRepository(SpringUserJpaRepository jpa) {
        this.jpa = jpa;
    }

    @Override
    public Optional<User> findById(int id) {
        return jpa.findById(id)
                  .map(UserJpaEntity::toDomain);
    }

    @Override
    public Optional<User> findByEmail(String email) {
        return jpa.findByEmail(email)
                  .map(UserJpaEntity::toDomain);
    }

    @Override
    public void save(User user) {
        jpa.save(UserJpaEntity.fromDomain(user));
    }
}
