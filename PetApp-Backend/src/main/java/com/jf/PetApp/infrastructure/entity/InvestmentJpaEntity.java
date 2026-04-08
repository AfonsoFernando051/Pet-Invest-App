package com.jf.PetApp.infrastructure.entity;

import com.jf.PetApp.core.domain.enums.InvestmentType;

import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;

@Entity
@Table(name = "jf_investments")
public class InvestmentJpaEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;

    @Enumerated(EnumType.STRING)
    private InvestmentType type;

    @ManyToOne(optional = false)
    @JoinColumn(name = "user_id", nullable = false)
    private UserJpaEntity user;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public InvestmentType getType() {
        return type;
    }

    public void setType(InvestmentType type) {
        this.type = type;
    }

    public UserJpaEntity getUser() {
        return user;
    }

    public void setUser(UserJpaEntity user) {
        this.user = user;
    }
}
