/**
 * Created by Ilya Matsuev on 2/28/2021.
 */

public with sharing class OrderProductComponentService extends OrderService implements IOrderProductComponentService {
    public List<ProductWrapper> getOrderedProducts(Order order) {
        try {
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
            throw new OrderProductComponentException(
                Label.UnexpectedErrorMessage
            );
        }
    }

    public Order activateOrder(Order order) {
        try {
            if (order.Status != 'Activated') {
                order.Status = 'Activated';
                orderDao.updateOrder(order);
                orderWebService.activateAsync(order);
            }
            return order;
        } catch (DmlException error) {
            throw new OrderProductComponentException(error.getDmlMessage(0));
        } catch (Exception error) {
            throw new OrderProductComponentException(
                Label.UnexpectedErrorMessage
            );
        }
    }
}
