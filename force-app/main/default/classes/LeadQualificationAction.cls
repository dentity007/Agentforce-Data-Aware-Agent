public class LeadQualificationAction {
    public class Request {
        @InvocableVariable(label='Lead ID' required=true)
        public Id leadId;
        @InvocableVariable(label='Score' required=true)
        public Integer score;
    }

    public class Response {
        @InvocableVariable(label='Success')
        public Boolean Success;
        @InvocableVariable(label='New Status')
        public String NewStatus;
    }

    @InvocableMethod(label='Update Lead Status' description='Updates lead status based on qualification score')
    public static List<Response> updateLeadStatus(List<Request> requests) {
        List<Response> responses = new List<Response>();
        List<Lead> leadsToUpdate = new List<Lead>();
        for (Request req : requests) {
            Response resp = new Response();
            try {
                Lead l = new Lead(Id = req.leadId);
                if (req.score >= 80) {
                    l.Status = 'Qualified';
                } else if (req.score >= 50) {
                    l.Status = 'Nurture';
                } else {
                    l.Status = 'Unqualified';
                }
                leadsToUpdate.add(l);
                resp.Success = true;
                resp.NewStatus = l.Status;
            } catch (Exception e) {
                resp.Success = false;
            }
            responses.add(resp);
        }
        if (!leadsToUpdate.isEmpty()) {
            update leadsToUpdate;
        }
        return responses;
    }
}