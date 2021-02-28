/**
 * Created by Ilya Matsuev on 2/26/2021.
 */

public interface IOrderDao {
    Order getById(Id id);

    List<OrderItem> upsertOrderItems(List<OrderItem> orderItems);

    Order updateOrder(Order order);
}
