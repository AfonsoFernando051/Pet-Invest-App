package com.jf.PetApp.application.auth.usecase;

import javax.naming.AuthenticationException;

import com.jf.PetApp.application.auth.dto.LoginCommand;
import com.jf.PetApp.application.auth.dto.LoginResult;

public interface LoginUseCase {
    LoginResult execute(LoginCommand command) throws AuthenticationException;
}
