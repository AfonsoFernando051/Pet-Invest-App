package com.jf.PetApp.infrastructure.entity;

import com.jf.PetApp.core.domain.User;
import com.jf.PetApp.core.domain.enums.RoleEnum;

import jakarta.persistence.CascadeType;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
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
    @Column(name="user_id")
    private int id;

    private String username;

    private String email;

    private String password;

    private boolean isActive;

    @Enumerated(EnumType.STRING)
    private RoleEnum role;

    @OneToOne(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true)
    private FinanceJpaEntity finance;

    @OneToOne(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true)
    private PetJpaEntity pet;

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
