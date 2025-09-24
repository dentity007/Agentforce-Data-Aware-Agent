public class InventoryCheckInvoker {
    public class InventoryResult {
        @AuraEnabled public Boolean inStock;
        @AuraEnabled public Integer quantity;
        @AuraEnabled public String productName;
        @AuraEnabled public String message;
    }

    public static String checkInventory(String productId, String category) {
        InventoryResult result = new InventoryResult();
        result.inStock = false;
        result.quantity = 0;

        try {
            // Query Product2 with dynamic inventory field discovery
            String inventoryField = MetadataDiscoverApex.findInventoryField('Product2');

            String query = 'SELECT Id, Name, ' + inventoryField +
                          ' FROM Product2 WHERE Id = :productId AND IsActive = true';

            List<Product2> products = Database.query(query);

            if (!products.isEmpty()) {
                Product2 prod = products[0];
                result.productName = prod.Name;

                // Get inventory quantity dynamically
                Object inventoryValue = prod.get(inventoryField);
                if (inventoryValue instanceof Integer) {
                    result.quantity = (Integer)inventoryValue;
                } else if (inventoryValue instanceof Decimal) {
                    result.quantity = ((Decimal)inventoryValue).intValue();
                }

                result.inStock = result.quantity > 0;

                if (result.inStock) {
                    result.message = result.productName + ' is in stock (' + result.quantity + ' available)';
                } else {
                    result.message = result.productName + ' is out of stock';
                }
            } else {
                result.message = 'Product not found';
            }

        } catch (Exception e) {
            result.message = 'Error checking inventory: ' + e.getMessage();
        }

        return JSON.serialize(result);
    }

    public static String findProductsInStock(String category, Integer minPrice, Integer maxPrice) {
        List<Map<String, Object>> results = new List<Map<String, Object>>();

        try {
            String inventoryField = MetadataDiscoverApex.findInventoryField('Product2');

            String query = 'SELECT Id, Name, ' + inventoryField + ', ProductCode, Description ' +
                          'FROM Product2 WHERE IsActive = true AND ' + inventoryField + ' > 0';

            if (String.isNotBlank(category)) {
                query += ' AND Family = :category';
            }

            List<Product2> products = Database.query(query);

            for (Product2 prod : products) {
                Map<String, Object> productInfo = new Map<String, Object>();
                productInfo.put('id', prod.Id);
                productInfo.put('name', prod.Name);
                productInfo.put('productCode', prod.ProductCode);
                productInfo.put('description', prod.Description);

                // Get inventory quantity
                Object inventoryValue = prod.get(inventoryField);
                Integer quantity = 0;
                if (inventoryValue instanceof Integer) {
                    quantity = (Integer)inventoryValue;
                } else if (inventoryValue instanceof Decimal) {
                    quantity = ((Decimal)inventoryValue).intValue();
                }
                productInfo.put('quantity', quantity);

                results.add(productInfo);
            }

        } catch (Exception e) {
            // Return error in results
            Map<String, Object> error = new Map<String, Object>();
            error.put('error', e.getMessage());
            results.add(error);
        }

        return JSON.serialize(results);
    }
}