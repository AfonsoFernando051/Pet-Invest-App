package com.jf.PetApp.application.mentor.usecase;

import com.jf.PetApp.application.mentor.dto.MentorChatRequest;

public interface GetMentorReplyUseCase {
    String execute(String email, MentorChatRequest request);
}
