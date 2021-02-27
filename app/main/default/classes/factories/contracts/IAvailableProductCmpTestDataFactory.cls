/**
 * Created by Ilya Matsuev on 2/27/2021.
 */

public interface IAvailableProductCmpTestDataFactory {
    Account createAccount(String name);

    Pricebook2 createPricebook(String name);

    List<Product2> createProducts(List<String> names);

    Contract createContract(Id accountId, Id pricebookId);

    Order createOrder(Id accountId, Id contractId, Id pricebookId);

    List<PricebookEntry> createPricebookEntries(
        Id pricebookId,
        List<Product2> products,
        List<Decimal> prices
    );

    List<OrderItem> createOrderItems(
        Id orderId,
        List<PricebookEntry> pricebookEntries
    );
}
