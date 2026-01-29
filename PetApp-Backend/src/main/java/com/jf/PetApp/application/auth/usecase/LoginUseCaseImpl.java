package com.jf.PetApp.application.auth.usecase;

import javax.naming.AuthenticationException;

import com.jf.PetApp.application.auth.dto.LoginCommand;
import com.jf.PetApp.application.auth.dto.LoginResult;
import com.jf.PetApp.application.auth.port.PasswordEncoderPort;
import com.jf.PetApp.application.auth.port.TokenProvider;
import com.jf.PetApp.application.user.port.UserRepository;
import com.jf.PetApp.core.domain.User;

public class LoginUseCaseImpl implements LoginUseCase {
    private final UserRepository userRepository;
    private final PasswordEncoderPort passwordEncoder;
    private final TokenProvider tokenProvider;

    public LoginUseCaseImpl(
            UserRepository userRepository,
            PasswordEncoderPort passwordEncoder,
            TokenProvider tokenProvider) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.tokenProvider = tokenProvider;
    }

    @Override
    public LoginResult execute(LoginCommand command) throws AuthenticationException {

        User user = userRepository.findByEmail(command.email())
                .orElseThrow(AuthenticationException::new);

        if (!passwordEncoder.matches(
                command.password(),
                user.getPassword())) {
            throw new AuthenticationException();
        }

        String accessToken = tokenProvider.generateToken(user);

        return new LoginResult(accessToken);
    }
}