package com.jf.PetApp.application.user.port;

import java.util.Optional;

import com.jf.PetApp.core.domain.User;

public interface UserRepository {
    Optional<User> findById(int id);

    Optional<User> findByEmail(String email);

    Optional<User> findByUsername(String username);

    User save(User user);
}
