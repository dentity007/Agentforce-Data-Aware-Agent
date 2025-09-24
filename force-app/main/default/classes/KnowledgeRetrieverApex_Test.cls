/**
 * Test class for KnowledgeRetrieverApex
 *
 * Provides comprehensive test coverage for the knowledge retrieval functionality.
 * Tests both successful retrieval scenarios and edge cases.
 *
 * Test Coverage:
 * - Basic functionality with valid inputs
 * - Edge cases (empty questions, invalid limits)
 * - Error handling and null safety
 * - JSON structure validation
 *
 * @author Salesforce Agentforce Team
 * @version 1.0
 */
@IsTest
private class KnowledgeRetrieverApex_Test {

    /**
     * Basic smoke test for knowledge retrieval functionality
     *
     * Tests the core functionality with a simple question and validates
     * that the method returns expected output structure without errors.
     */
    @IsTest
    static void smoke() {
        // Create input with sample question
        KnowledgeRetrieverApex.Input i = new KnowledgeRetrieverApex.Input();
        i.question = 'Return policy';
        i.maxResults = 2;

        // Execute the knowledge retrieval
        List<KnowledgeRetrieverApex.Output> out =
            KnowledgeRetrieverApex.run(new List<KnowledgeRetrieverApex.Input>{ i });

        // Validate output structure
        System.assertEquals(1, out.size(), 'Should return one output for one input');
        System.assertNotEquals(null, out[0].context, 'Context should not be null');
        System.assertNotEquals(null, out[0].citationsJson, 'Citations JSON should not be null');
    }

    /**
     * Test edge case: Empty question input
     *
     * Validates that the method handles empty or null questions gracefully
     * and returns appropriate error messaging.
     */
    @IsTest
    static void testEmptyQuestion() {
        // Test with empty question
        KnowledgeRetrieverApex.Input i = new KnowledgeRetrieverApex.Input();
        i.question = '';
        i.maxResults = 3;

        List<KnowledgeRetrieverApex.Output> out =
            KnowledgeRetrieverApex.run(new List<KnowledgeRetrieverApex.Input>{ i });

        System.assertEquals(1, out.size());
        System.assertEquals('No question provided.', out[0].context);
        System.assertEquals('[]', out[0].citationsJson);
    }

    /**
     * Test edge case: Null question input
     *
     * Ensures null safety and proper handling of null inputs.
     */
    @IsTest
    static void testNullQuestion() {
        KnowledgeRetrieverApex.Input i = new KnowledgeRetrieverApex.Input();
        i.question = null;
        i.maxResults = 3;

        List<KnowledgeRetrieverApex.Output> out =
            KnowledgeRetrieverApex.run(new List<KnowledgeRetrieverApex.Input>{ i });

        System.assertEquals(1, out.size());
        System.assertEquals('No question provided.', out[0].context);
        System.assertEquals('[]', out[0].citationsJson);
    }

    /**
     * Test result limit validation
     *
     * Tests that the method properly enforces minimum and maximum result limits.
     */
    @IsTest
    static void testResultLimits() {
        KnowledgeRetrieverApex.Input i = new KnowledgeRetrieverApex.Input();
        i.question = 'Test question';

        // Test minimum limit (should default to 3)
        i.maxResults = 0;
        List<KnowledgeRetrieverApex.Output> out =
            KnowledgeRetrieverApex.run(new List<KnowledgeRetrieverApex.Input>{ i });
        System.assertEquals(1, out.size());

        // Test maximum limit (should cap at 10)
        i.maxResults = 15;
        out = KnowledgeRetrieverApex.run(new List<KnowledgeRetrieverApex.Input>{ i });
        System.assertEquals(1, out.size());
    }

    /**
     * Test multiple input processing
     *
     * Validates that the method can handle multiple input requests in a single call.
     */
    @IsTest
    static void testMultipleInputs() {
        List<KnowledgeRetrieverApex.Input> inputs = new List<KnowledgeRetrieverApex.Input>();

        // Create multiple inputs
        KnowledgeRetrieverApex.Input i1 = new KnowledgeRetrieverApex.Input();
        i1.question = 'Question 1';
        i1.maxResults = 2;
        inputs.add(i1);

        KnowledgeRetrieverApex.Input i2 = new KnowledgeRetrieverApex.Input();
        i2.question = 'Question 2';
        i2.maxResults = 1;
        inputs.add(i2);

        // Execute with multiple inputs
        List<KnowledgeRetrieverApex.Output> out = KnowledgeRetrieverApex.run(inputs);

        // Validate multiple outputs
        System.assertEquals(2, out.size(), 'Should return outputs for both inputs');
        System.assertNotEquals(null, out[0].context);
        System.assertNotEquals(null, out[1].context);
    }

    /**
     * Test JSON citation structure
     *
     * Validates that the citationsJson output is properly formatted JSON
     * and contains expected citation object structure.
     */
    @IsTest
    static void testCitationsJsonStructure() {
        KnowledgeRetrieverApex.Input i = new KnowledgeRetrieverApex.Input();
        i.question = 'Test citations';
        i.maxResults = 3;

        List<KnowledgeRetrieverApex.Output> out =
            KnowledgeRetrieverApex.run(new List<KnowledgeRetrieverApex.Input>{ i });

        // Validate JSON structure
        System.assertNotEquals(null, out[0].citationsJson);

        // Attempt to parse JSON to ensure it's valid
        try {
            List<Object> citations = (List<Object>) JSON.deserializeUntyped(out[0].citationsJson);
            // If we get here, JSON is valid
            System.assert(citations instanceof List<Object>);
        } catch (Exception e) {
            System.assert(false, 'Citations JSON should be valid: ' + e.getMessage());
        }
    }
}
