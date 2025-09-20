public class LeadScoreService {
    public class ScoreResult {
        @AuraEnabled public Integer score;
        @AuraEnabled public String reason;
    }

    public static ScoreResult scoreLead(Id leadId) {
        ScoreResult result = new ScoreResult();
        // Simple scoring logic: random for demo
        result.score = Math.mod(Math.abs(Crypto.getRandomInteger()), 101);
        result.reason = 'Random score for demo purposes';
        return result;
    }
}