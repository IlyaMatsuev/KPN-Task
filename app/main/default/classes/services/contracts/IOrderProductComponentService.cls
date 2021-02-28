/**
 * Created by Ilya Matsuev on 2/28/2021.
 */

public interface IOrderProductComponentService extends IOrderService {
    List<ProductWrapper> getOrderedProducts(Order order);

    Order activateOrder(Order order);
}
