package com.jf.PetApp.infrastructure.controller.mentor;

import com.jf.PetApp.application.mentor.dto.MentorChatRequest;
import com.jf.PetApp.application.mentor.dto.MentorChatResponse;
import com.jf.PetApp.application.mentor.usecase.GetMentorReplyUseCase;
import com.jf.PetApp.core.security.SecurityUtils;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/mentor")
public class MentorController {

    private final GetMentorReplyUseCase getMentorReplyUseCase;

    public MentorController(GetMentorReplyUseCase getMentorReplyUseCase) {
        this.getMentorReplyUseCase = getMentorReplyUseCase;
    }

    @PostMapping("/chat")
    public ResponseEntity<MentorChatResponse> chat(@Valid @RequestBody MentorChatRequest request) {
        String email = SecurityUtils.getCurrentUserEmail();
        String reply = getMentorReplyUseCase.execute(email, request);
        return ResponseEntity.ok(new MentorChatResponse(reply));
    }
}
