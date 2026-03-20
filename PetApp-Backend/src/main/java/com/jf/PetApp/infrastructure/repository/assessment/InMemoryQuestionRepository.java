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
        )),
        new Question("q4", "When markets are volatile, which action feels most like you?", List.of(
            new Option("q4_1", "Avoid risk and focus on capital protection", 0),
            new Option("q4_2", "Rebalance gradually and keep a long-term plan", 2),
            new Option("q4_3", "Increase exposure when prices drop, accepting swings", 4)
        )),
        new Question("q5", "How important is the possibility of large short-term losses to you?", List.of(
            new Option("q5_1", "Very important - I prefer smaller, steadier outcomes", 0),
            new Option("q5_2", "Somewhat important - I can tolerate losses for better upside", 2),
            new Option("q5_3", "Not very important - I prioritize growth even if it hurts", 4)
        ))
    );

    @Override
    public List<Question> findAll() {
        return QUESTIONS;
    }
}
