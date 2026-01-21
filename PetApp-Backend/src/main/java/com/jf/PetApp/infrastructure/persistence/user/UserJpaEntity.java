package com.jf.PetApp.infrastructure.persistence.user;

import com.jf.PetApp.domain.User;
import com.jf.PetApp.infrastructure.persistence.finance.FinanceJpaEntity;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.OneToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "jf_users")
public class UserJpaEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    private String username;

    private String email;

    private String password;

    @OneToOne(mappedBy = "user", cascade = CascadeType.ALL)
    private FinanceJpaEntity finance;

    /* ---------- Mapping ---------- */

    public static UserJpaEntity fromDomain(User user) {
        UserJpaEntity entity = new UserJpaEntity();
        entity.id = user.getId();
        entity.username = user.getUsername();
        entity.email = user.getEmail();
        entity.password = user.getPassword();
        return entity;
    }

    public User toDomain() {
        User user = new User();
        user.setId(id);
        user.setUsername(username);
        user.setEmail(email);
        user.setPassword(password);
        return user;
    }
}
