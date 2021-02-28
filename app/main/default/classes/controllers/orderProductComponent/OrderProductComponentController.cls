/**
 * Created by Ilya Matsuev on 2/27/2021.
 */

public with sharing class OrderProductComponentController {
    private static final IOrderService orderService = new OrderService();

    /**
     * @description Returns products that are assigned to the order
     * @return List of ProductWrapper which contains products` id, name, quantity and price (unit and total)
     * */
    @AuraEnabled(Cacheable=true)
    public static List<ProductWrapper> getOrderedProducts(Id orderId) {
        try {
            Order order = orderService.getOrder(orderId);
            List<ProductWrapper> products = new List<ProductWrapper>();
            for (OrderItem orderItem : order.OrderItems) {
                products.add(
                    new ProductWrapper(
                        orderItem.Product2.Id,
                        orderItem.Product2.Name,
                        orderItem.UnitPrice,
                        orderItem.Quantity,
                        orderItem.TotalPrice
                    )
                );
            }
            return products;
        } catch (Exception error) {
            throw new AuraHandledException(error.getMessage());
        }
    }
}
