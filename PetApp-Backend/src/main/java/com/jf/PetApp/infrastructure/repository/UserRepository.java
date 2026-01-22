package com.jf.PetApp.infrastructure.repository;

import com.jf.PetApp.domain.User;

import java.util.Optional;

public interface UserRepository {
	Optional<User> findById(int id);

    Optional<User> findByEmail(String email);

    void save(User user);
}
