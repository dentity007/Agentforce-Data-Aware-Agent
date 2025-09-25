public with sharing class CodeGenService {
    public static PlanModels.CodeArtifacts generate(PlanModels.Plan plan) {
        // Stub: In future, stitch LLM-generated files. For now, return empty arrays.
        PlanModels.CodeArtifacts ca = new PlanModels.CodeArtifacts();
        ca.apex = new List<Map<String, String>>();
        ca.soql = new List<String>();
        ca.tests = new List<Map<String, String>>();
        return ca;
    }
}
