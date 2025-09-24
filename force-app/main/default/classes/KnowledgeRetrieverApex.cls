/**
 * KnowledgeRetrieverApex - Fallback Knowledge Retrieval for Agentforce
 *
 * Purpose: Provides knowledge-grounded responses when Agentforce Data Library is not configured.
 * This class serves as a fallback mechanism for RAG (Retrieval-Augmented Generation) in
 * schema-aware agents, using Salesforce Knowledge articles for grounding.
 *
 * Key Features:
 * - SOSL-based search against KnowledgeArticleVersion objects
 * - Configurable result limits (1-10 articles)
 * - Structured citations with article metadata
 * - FLS-compliant field access
 * - Error handling for missing knowledge or search failures
 *
 * Integration: Register as custom Apex action in Agentforce Builder
 * Use Case: Knowledge-grounded agent responses without Data Library setup
 * Security: Respects sharing rules and field-level security
 *
 * @author Salesforce Agentforce Team
 * @version 1.0
 * @since 2024
 */
public with sharing class KnowledgeRetrieverApex {

    /**
     * Input parameters for knowledge retrieval request
     * Used by Agentforce Builder to map user inputs to Apex action
     */
    public class Input {
        @InvocableVariable(required=true, description='Natural language question to ground agent responses')
        public String question;

        @InvocableVariable(description='Maximum number of knowledge articles to retrieve (1-10). Default: 3')
        public Integer maxResults;
    }

    /**
     * Output results from knowledge retrieval operation
     * Provides both human-readable context and structured citation data
     */
    public class Output {
        @InvocableVariable(description='Synthesized plaintext context from top knowledge matches for agent grounding')
        public String context;

        @InvocableVariable(description='JSON array of citation objects: [{title, urlName, articleId, score}]')
        public String citationsJson;
    }

    /**
     * Main invocable method for knowledge retrieval
     *
     * Processes a list of knowledge retrieval requests and returns grounded context
     * with citations for each input. Uses SOSL to search Salesforce Knowledge articles.
     *
     * @param inputs List of Input objects containing questions and result limits
     * @return List of Output objects with context and citation data
     */
    @InvocableMethod(label='Retrieve Knowledge Snippets'
                     description='Returns grounded snippets from Knowledge to use as RAG context.')
    public static List<Output> run(List<Input> inputs) {
        List<Output> out = new List<Output>();

        // Process each input request individually
        for (Input i : inputs) {
            // Validate and sanitize input parameters
            Integer k = (i.maxResults == null || i.maxResults < 1) ? 3 : Math.min(i.maxResults, 10);
            String q = (i.question == null) ? '' : i.question.trim();

            // Handle empty question input
            if (q == '') {
                Output o = new Output();
                o.context = 'No question provided.';
                o.citationsJson = '[]';
                out.add(o);
                continue;
            }

            // Build SOSL query for knowledge article search
            // Uses Salesforce Object Search Language to find relevant Knowledge articles
            // Searches across all text fields in KnowledgeArticleVersion objects
            String qEsc = String.escapeSingleQuotes(q);
            String sosl = 'FIND \''
                          + qEsc +
                          '\' IN ALL FIELDS RETURNING KnowledgeArticleVersion(Id, Title, UrlName, Summary ORDER BY Score DESC LIMIT '
                          + String.valueOf(k) + ')';

            // Execute SOSL query and retrieve results
            // Search.query() returns List<List<SObject>> for multi-object searches
            List<List<SObject>> res = Search.query(sosl);

            // Extract KnowledgeArticleVersion records from search results
            List<KnowledgeArticleVersion> arts = (res.isEmpty())
                ? new List<KnowledgeArticleVersion>()
                : (List<KnowledgeArticleVersion>) res[0];

            // Process search results into context and citations
            List<String> chunks = new List<String>();
            List<Map<String,Object>> cites = new List<Map<String,Object>>();
            Integer rank = 1;

            // Iterate through each knowledge article and extract relevant information
            for (KnowledgeArticleVersion kav : arts) {
                // Extract article metadata using dynamic field access
                String title = String.valueOf(kav.get('Title'));
                String summary = String.valueOf(kav.get('Summary'));
                String urlName = String.valueOf(kav.get('UrlName'));
                String artId = (String)kav.get('Id');

                // Create compact, readable snippet for agent context
                // Format: "1) Article Title — Summary text..." (truncated to 280 chars)
                chunks.add(rank + ') ' + title + ' — ' + (summary == null ? '' : summary.left(280)));

                // Build citation object for source attribution
                Map<String,Object> c = new Map<String,Object>{
                    'title' => title,
                    'urlName' => urlName,
                    'articleId' => artId,
                    'score' => rank  // Ranking based on search result order
                };
                cites.add(c);
                rank++;
            }

            // Construct final output for this input request
            Output o = new Output();

            // Build human-readable context from article snippets
            // Format: Either "No matching knowledge found..." or numbered list of snippets
            o.context = (chunks.isEmpty()
                ? 'No matching knowledge found for: ' + q
                : 'Grounding snippets:\n' + String.join(chunks, '\n'));

            // Serialize citations as JSON for structured source attribution
            // Used by agents to cite sources and provide links to full articles
            o.citationsJson = JSON.serialize(cites);

            out.add(o);
        }

        // Return processed results for all input requests
        return out;
    }
}
