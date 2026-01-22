package com.jf.PetApp.infrastructure.entity;

import com.jf.PetApp.domain.Pet;
import com.jf.PetApp.domain.enums.PetSpecieEnum;
import com.jf.PetApp.domain.User;

import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "jf_pets")
public class PetJpaEntity {
	
	@Id
    private int id;

    private String name;

    private int health;

    @Enumerated(EnumType.STRING)
    private PetSpecieEnum specie;

    private int userId;

    public static PetJpaEntity fromDomain(Pet pet) {
        PetJpaEntity entity = new PetJpaEntity();
        entity.id = pet.getId();
        entity.name = pet.getName();
        entity.health = pet.getHealth();
        entity.specie = pet.getSpecie();
        entity.userId = pet.getUser().getId();
        return entity;
    }

    public Pet toDomain(User user) {
        Pet pet = new Pet();
        pet.setId(id);
        pet.setName(name);
        pet.setHealth(health);
        pet.setSpecie(specie);
        pet.setUser(user);
        return pet;
    }
}
