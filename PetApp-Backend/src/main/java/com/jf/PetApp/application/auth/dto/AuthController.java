package com.jf.PetApp.application.auth.dto;

import javax.naming.AuthenticationException;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.jf.PetApp.application.auth.exception.UserAlreadyExistsException;
import com.jf.PetApp.application.auth.usecase.LoginUseCase;
import com.jf.PetApp.application.auth.usecase.RegisterUserUseCase;
import com.jf.PetApp.presentation.auth.dto.RegisterRequest;
import com.jf.PetApp.presentation.auth.dto.RegisterResponse;

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
        @RequestBody LoginRequest request
    ) throws AuthenticationException {
        LoginResult result = loginUseCase.execute(
            new LoginCommand(request.email(), request.password())
        );

        return ResponseEntity.ok(
            new LoginResponse(result.accessToken())
        );
    }
    
    @PostMapping("/register")
    public ResponseEntity<RegisterResponse> register(
        @RequestBody RegisterRequest request
    ) {
        RegisterResult result = registerUserUseCase.execute(
            new RegisterCommand(
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
    
    @ExceptionHandler(UserAlreadyExistsException.class)
    public ResponseEntity<?> handleUserAlreadyExists() {
        return ResponseEntity
            .status(HttpStatus.CONFLICT)
            .body("User already exists");
    }
}
