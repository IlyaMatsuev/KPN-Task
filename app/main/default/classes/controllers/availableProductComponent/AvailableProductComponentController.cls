/**
 * Created by Ilya Matsuev on 2/25/2021.
 */

public with sharing class AvailableProductComponentController {
    private final static IAvailableProductComponentService service = new AvailableProductComponentService();

    /**
     * @description Returns products that are assigned to the order or to its pricebook
     * @return List of ProductWrapper which contains products` id, name, price and the field showing if product assigned to the order
     * */
    @AuraEnabled(Cacheable=true)
    public static List<ProductWrapper> getAvailableProducts(
        Id orderId,
        String productNameSearchTerm
    ) {
        try {
            Order order = service.getOrder(orderId);
            return service.getAvailableProducts(order, productNameSearchTerm);
        } catch (AvailableProductComponentException error) {
            throw new AuraHandledException(error.getMessage());
        }
    }

    /**
     * @description Updates order items for products that are already assigned to the order. Creates new order items for other products.
     * @return List of increased & assigned products
     * */
    @AuraEnabled
    public static List<ProductWrapper> addProducts(
        Id orderId,
        String serializedProducts
    ) {
        try {
            Order order = service.getOrder(orderId);
            List<ProductWrapper> products = (List<ProductWrapper>) JSON.deserialize(
                serializedProducts,
                List<ProductWrapper>.class
            );
            return service.addProducts(order, products);
        } catch (AvailableProductComponentException error) {
            throw new AuraHandledException(error.getMessage());
        }
    }
}
