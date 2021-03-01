/**
 * Created by Ilya Matsuev on 2/27/2021.
 */

public with sharing class OrderProductComponentController {
    private static final IOrderProductComponentService service = new OrderProductComponentService();

    /**
     * @description Returns products that are assigned to the order
     * @return List of ProductWrapper which contains products` id, name, quantity and price (unit and total)
     * */
    @AuraEnabled(Cacheable=true)
    public static List<ProductWrapper> getOrderedProducts(Id orderId) {
        try {
            Order order = service.getOrder(orderId);
            return service.getOrderedProducts(order);
        } catch (OrderProductComponentException error) {
            throw new AuraHandledException(error.getMessage());
        }
    }

    /**
     * @description Sets status of the order to 'Activated'
     * @return Returns updated order
     * */
    @AuraEnabled
    public static Order activateOrder(Id orderId) {
        try {
            Order order = service.getOrder(orderId);
            return service.activateOrder(order);
        } catch (OrderProductComponentException error) {
            throw new AuraHandledException(error.getMessage());
        }
    }
}
