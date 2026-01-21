package com.jf.PetApp.domain;

import java.util.Optional;

public interface UserRepository {
	Optional<User> findById(int id);

    Optional<User> findByEmail(String email);

    void save(User user);
}
