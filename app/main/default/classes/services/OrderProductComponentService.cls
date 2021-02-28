/**
 * Created by Ilya Matsuev on 2/28/2021.
 */

public with sharing class OrderProductComponentService extends OrderService implements IOrderProductComponentService {
    public List<ProductWrapper> getOrderedProducts(Order order) {
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
    }

    public Order activateOrder(Order order) {
        if (order.Status != 'Activated') {
            order.Status = 'Activated';
            orderDao.updateOrder(order);
        }
        return order;
    }
}
