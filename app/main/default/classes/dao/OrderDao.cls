/**
 * Created by Ilya Matsuev on 2/25/2021.
 */

public with sharing class OrderDao implements IOrderDao {
    public Order getById(Id id) {
        List<Order> orders = [
            SELECT
                Pricebook2Id,
                OrderNumber,
                Account.AccountNumber,
                Type,
                Status,
                (
                    SELECT
                        OrderId,
                        PricebookEntryId,
                        Quantity,
                        UnitPrice,
                        ListPrice,
                        TotalPrice,
                        Product2.Id,
                        Product2.Name,
                        Product2.ProductCode
                    FROM OrderItems
                )
            FROM Order
            WHERE Id = :id
            LIMIT 1
        ];
        if (orders.isEmpty()) {
            throw new QueryException(Label.NoOrderErrorMessage);
        }
        return orders.get(0);
    }

    public List<OrderItem> upsertOrderItems(List<OrderItem> orderItems) {
        Database.upsert(orderItems);
        return orderItems;
    }

    public Order updateOrder(Order order) {
        Database.update(order);
        return order;
    }
}
