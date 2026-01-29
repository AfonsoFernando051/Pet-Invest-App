package com.jf.PetApp.application.auth.dto;

import javax.naming.AuthenticationException;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.jf.PetApp.application.auth.usecase.LoginUseCase;

@RestController
@RequestMapping("/auth")
public class AuthController {

    private final LoginUseCase loginUseCase;

    public AuthController(LoginUseCase loginUseCase) {
        this.loginUseCase = loginUseCase;
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
}
