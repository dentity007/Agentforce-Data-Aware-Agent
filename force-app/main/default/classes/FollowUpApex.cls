public class FollowUpApex {
    public class Input {
        @InvocableVariable(label='Lead ID' required=true)
        public Id LeadId;
        @InvocableVariable(label='Channel' required=true)
        public String Channel;
        @InvocableVariable(label='Template Name' required=false)
        public String TemplateName;
    }

    public class Output {
        @InvocableVariable(label='Success')
        public Boolean Success;
        @InvocableVariable(label='Task ID')
        public Id TaskId;
    }

    @InvocableMethod(label='Create Follow-Up' description='Creates a follow-up task for the lead')
    public static List<Output> execute(List<Input> inputs) {
        List<Output> outputs = new List<Output>();
        for (Input inp : inputs) {
            Output out = new Output();
            try {
                Task t = new Task();
                t.WhoId = inp.LeadId;
                t.Subject = 'Follow-up on Lead';
                t.Status = 'Not Started';
                t.Priority = 'Normal';
                t.Description = 'Automated follow-up via GenAI Agent';
                insert t;
                out.Success = true;
                out.TaskId = t.Id;
            } catch (Exception e) {
                out.Success = false;
            }
            outputs.add(out);
        }
        return outputs;
    }
}