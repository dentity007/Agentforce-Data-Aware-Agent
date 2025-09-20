public class SchemaGraphStore {
    private static OrgSchemaBootstrap.SchemaGraphDTO cachedGraph;

    public static OrgSchemaBootstrap.SchemaGraphDTO load() {
        if (cachedGraph == null) {
            // Load from custom object or cache
            cachedGraph = new OrgSchemaBootstrap.SchemaGraphDTO();
        }
        return cachedGraph;
    }

    public static void store(OrgSchemaBootstrap.SchemaGraphDTO graph) {
        cachedGraph = graph;
        // Persist to custom object if needed
    }
}