package com.jf.PetApp.infrastructure.repository.assessment;

import com.jf.PetApp.core.domain.assessment.Option;
import com.jf.PetApp.core.domain.assessment.Question;
import com.jf.PetApp.core.port.QuestionRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public class InMemoryQuestionRepository implements QuestionRepository {
    
    private static final List<Question> QUESTIONS = List.of(
        new Question("q1", "What is your main goal for investing?", List.of(
            new Option("q1_1", "Preserve my money at all costs", 0),
            new Option("q1_2", "Steady growth with moderate risk", 2),
            new Option("q1_3", "Maximize returns, I can handle volatility", 4)
        )),
        new Question("q2", "How would you react if your portfolio drops 20% in a week?", List.of(
            new Option("q2_1", "Sell everything immediately out of fear", 0),
            new Option("q2_2", "Hold and wait for recovery", 2),
            new Option("q2_3", "Buy more at a discount", 4)
        )),
        new Question("q3", "What is your investment time horizon?", List.of(
            new Option("q3_1", "Less than 1 year (need liquidity soon)", 0),
            new Option("q3_2", "1 to 5 years", 2),
            new Option("q3_3", "More than 5 years (long term player)", 4)
        ))
    );

    @Override
    public List<Question> findAll() {
        return QUESTIONS;
    }
}
