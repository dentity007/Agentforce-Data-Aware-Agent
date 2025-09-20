public class OrgSchemaNightlyJob implements Schedulable {
    public static void scheduleNightly() {
        // Schedule the job to run nightly
        System.schedule('Org Schema Refresh', '0 0 1 * * ?', new OrgSchemaNightlyJob());
    }

    public void execute(SchedulableContext sc) {
        // Refresh schema graph
        OrgSchemaBootstrap.buildSchemaGraph();
    }
}