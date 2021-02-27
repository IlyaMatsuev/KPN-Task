/**
 * Created by Ilya Matsuev on 2/27/2021.
 */

public with sharing class AvailableProductCmpTestDataFactory implements IAvailableProductCmpTestDataFactory {
    public final static Integer DEFAULT_ORDER_ITEM_QUANTITY = 1;

    public Account createAccount(String name) {
        return new Account(Name = name);
    }

    public Pricebook2 createPricebook(String name) {
        return new Pricebook2(Name = name, IsActive = true);
    }

    public List<Product2> createProducts(List<String> names) {
        List<Product2> products = new List<Product2>();
        for (String name : names) {
            products.add(new Product2(Name = name, IsActive = true));
        }
        return products;
    }

    public Contract createContract(Id accountId, Id pricebookId) {
        return new Contract(
            Status = 'Draft',
            StartDate = Date.today().addDays(1),
            ContractTerm = 3,
            AccountId = accountId,
            Pricebook2Id = pricebookId
        );
    }

    public Order createOrder(Id accountId, Id contractId, Id pricebookId) {
        return new Order(
            EffectiveDate = Date.today().addMonths(1),
            Status = 'Draft',
            AccountId = accountId,
            ContractId = contractId,
            Pricebook2Id = pricebookId
        );
    }

    public List<PricebookEntry> createPricebookEntries(
        Id pricebookId,
        List<Product2> products,
        List<Decimal> prices
    ) {
        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>();
        for (Integer i = 0; i < prices.size() && i < products.size(); i++) {
            pricebookEntries.add(
                new PricebookEntry(
                    Pricebook2Id = pricebookId,
                    Product2Id = products.get(i).Id,
                    IsActive = true,
                    UnitPrice = prices.get(i)
                )
            );
        }
        return pricebookEntries;
    }

    public List<OrderItem> createOrderItems(
        Id orderId,
        List<PricebookEntry> pricebookEntries
    ) {
        List<OrderItem> orderItems = new List<OrderItem>();
        for (PricebookEntry pricebookEntry : pricebookEntries) {
            orderItems.add(
                new OrderItem(
                    OrderId = orderId,
                    Product2Id = pricebookEntry.Product2Id,
                    PricebookEntryId = pricebookEntry.Id,
                    Quantity = DEFAULT_ORDER_ITEM_QUANTITY,
                    UnitPrice = pricebookEntry.UnitPrice,
                    ListPrice = pricebookEntry.UnitPrice
                )
            );
        }
        return orderItems;
    }
}
