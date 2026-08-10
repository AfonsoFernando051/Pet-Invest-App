package com.jf.PetApp.infrastructure.controller.auth;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.jf.PetApp.application.auth.dto.LoginCommand;
import com.jf.PetApp.application.auth.dto.LoginRequest;
import com.jf.PetApp.application.auth.dto.LoginResponse;
import com.jf.PetApp.application.auth.dto.LoginResult;
import com.jf.PetApp.application.auth.dto.RegisterCommand;
import com.jf.PetApp.application.auth.dto.RegisterResult;
import com.jf.PetApp.application.auth.usecase.LoginUseCase;
import com.jf.PetApp.application.auth.usecase.RegisterUserUseCase;
import com.jf.PetApp.presentation.auth.dto.RegisterRequest;
import com.jf.PetApp.presentation.auth.dto.RegisterResponse;

import jakarta.validation.Valid;

@RestController
@RequestMapping("/auth")
public class AuthController {

    private final LoginUseCase loginUseCase;
    private final RegisterUserUseCase registerUserUseCase;

    public AuthController(LoginUseCase loginUseCase, RegisterUserUseCase registerUserUseCase) {
        this.loginUseCase = loginUseCase;
        this.registerUserUseCase = registerUserUseCase;
    }

    @PostMapping("/login")
    public ResponseEntity<LoginResponse> login(
        @Valid @RequestBody LoginRequest request
    ) {
        LoginResult result = loginUseCase.execute(
            new LoginCommand(request.email(), request.password())
        );

        return ResponseEntity.ok(
            new LoginResponse(result.accessToken())
        );
    }

    @PostMapping("/register")
    public ResponseEntity<RegisterResponse> register(
        @Valid @RequestBody RegisterRequest request
    ) {
        RegisterResult result = registerUserUseCase.execute(
            new RegisterCommand(
                request.username(),
                request.email(),
                request.password()
            )
        );

        return ResponseEntity.status(HttpStatus.CREATED)
            .body(new RegisterResponse(
                result.userId(),
                result.email()
            ));
    }
}
