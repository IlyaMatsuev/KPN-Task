/**
 * Created by Ilya Matsuev on 2/25/2021.
 */

public with sharing class OrderDao implements IOrderDao {
  public Order getById(Id id) {
    List<Order> orders = [
      SELECT
        Id,
        Pricebook2Id,
        (SELECT Id, OrderId, PricebookEntryId FROM OrderItems)
      FROM Order
      WHERE Id = :id
    ];
    if (orders.isEmpty()) {
      throw new QueryException('There is no such order with of id: ' + id);
    }
    return orders.get(0);
  }
}
