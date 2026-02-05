package com.jf.PetApp.infrastructure.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import com.jf.PetApp.application.auth.port.PasswordEncoderPort;
import com.jf.PetApp.application.auth.port.TokenProvider;
import com.jf.PetApp.application.auth.usecase.LoginUseCase;
import com.jf.PetApp.application.auth.usecase.LoginUseCaseImpl;
import com.jf.PetApp.application.auth.usecase.RegisterUserUseCase;
import com.jf.PetApp.application.auth.usecase.RegisterUserUseCaseImpl;
import com.jf.PetApp.application.user.port.UserRepository;

@Configuration
public class AuthUseCaseConfig {

    @Bean
    public LoginUseCase loginUseCase(
        UserRepository userRepository,
        PasswordEncoderPort passwordEncoder,
        TokenProvider tokenProvider
    ) {
        return new LoginUseCaseImpl(
            userRepository,
            passwordEncoder,
            tokenProvider
        );
    }
    
    @Bean
    public RegisterUserUseCase registerUserUseCase(
        UserRepository userRepository,
        PasswordEncoderPort passwordEncoder
    ) {
        return new RegisterUserUseCaseImpl(
            userRepository,
            passwordEncoder
        );
    }
}