public class JSONUtil {
    public static String minify(String jsonString) {
        if (String.isBlank(jsonString)) return jsonString;
        return jsonString.replaceAll('\\s+', ' ').trim();
    }
}