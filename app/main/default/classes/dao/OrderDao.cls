/**
 * Created by Ilya Matsuev on 2/25/2021.
 */

public with sharing class OrderDao implements IOrderDao {
    public Order getById(Id id) {
        List<Order> orders = [
            SELECT
                Pricebook2Id,
                (
                    SELECT OrderId, PricebookEntryId, Product2.Id, Quantity
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
}
