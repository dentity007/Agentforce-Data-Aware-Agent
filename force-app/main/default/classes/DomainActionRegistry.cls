public with sharing class DomainActionRegistry {
    public class Template {
        @AuraEnabled public String name;
        @AuraEnabled public String type; // CRUD or DOMAIN
        @AuraEnabled public String sobjectApiName;
        @AuraEnabled public List<String> requiredFields;
    }

    public static Map<String, Template> registry() {
        Map<String, Template> r = new Map<String, Template>();
        Template t1 = new Template();
        t1.name = 'UpdateOpportunityStage';
        t1.type = 'DOMAIN';
        t1.sobjectApiName = 'Opportunity';
        t1.requiredFields = new List<String>{'Id','StageName'};
        r.put(t1.name, t1);

        Template t2 = new Template();
        t2.name = 'CRUD.Upsert';
        t2.type = 'CRUD';
        t2.sobjectApiName = 'Generic__c';
        t2.requiredFields = new List<String>{'Id'};
        r.put(t2.name, t2);
        return r;
    }
}
