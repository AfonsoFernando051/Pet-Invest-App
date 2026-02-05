package com.jf.PetApp.core.domain;

import com.jf.PetApp.core.domain.enums.RoleEnum;

public class User {

	/**
	 * Id for pet
	 */
	Long id;

	/**
	 * Name for user
	 */
	String username;

	/**
	 * Name for user
	 */
	String email;

	/**
	 * Password for user
	 */
	String password;

	/**
	 * The user's pet
	 */
	Pet pet;

	/**
	 * The user's pet
	 */
	Finance finance;

	/**
	 * The user's role
	 */
	RoleEnum role;

	/**
	 * The user's active status
	 */
	boolean isActive;

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public String getUsername() {
		return username;
	}

	public void setUsername(String username) {
		this.username = username;
	}

	public String getEmail() {
		return email;
	}

	public void setEmail(String email) {
		this.email = email;
	}

	public String getPassword() {
		return password;
	}

	public void setPassword(String password) {
		this.password = password;
	}

	public Pet getPet() {
		return pet;
	}

	public void setPet(Pet pet) {
		this.pet = pet;
	}

	public Finance getFinance() {
		return finance;
	}

	public void setFinance(Finance finance) {
		this.finance = finance;
	}

	public RoleEnum getRole() {
		return role;
	}

	public void setRole(RoleEnum role) {
		this.role = role;
	}

	public boolean isActive() {
		return isActive;
	}

	public void setActive(boolean isActive) {
		this.isActive = isActive;
	}

	public static User create(String email, String password, RoleEnum role) {
		User user = new User();
		user.setEmail(email);
		user.setPassword(password);
		user.setRole(role);
		user.setActive(true);
		return user;
	}

}
