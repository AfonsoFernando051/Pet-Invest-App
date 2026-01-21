package com.jf.PetApp.domain;

public class Pet {
	
	/**
	 * Id for pet
	 */
	int id;

	/**
	 * Name for pet
	 */
	String name;

	/**
	 * Specie for pet
	 */
	PetSpecie specie;
	
	/**
	 * Pet health
	 */
	int health;
	
	/**
	 * The user's pet
	 */
	User user;
	
	public int getId() {
		return id;
	}
	public void setId(int id) {
		this.id = id;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public PetSpecie getSpecie() {
		return specie;
	}
	public void setSpecie(PetSpecie specie) {
		this.specie = specie;
	}
	public int getHealth() {
		return health;
	}
	public void setHealth(int health) {
		this.health = health;
	}
	public User getUser() {
		return user;
	}
	public void setUser(User user) {
		this.user = user;
	}
	
}
