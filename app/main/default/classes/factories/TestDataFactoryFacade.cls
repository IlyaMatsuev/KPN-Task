/**
 * Created by Ilya Matsuev on 2/28/2021.
 */

public with sharing class TestDataFactoryFacade implements ITestDataFactoryFacade {
    private final IOrderCmpTestDataFactory factory { get; set; }

    public TestDataFactoryFacade(IOrderCmpTestDataFactory factory) {
        this.factory = factory;
    }

    public void setup(
        String accountName,
        String pricebookName,
        List<String> productNames,
        List<Decimal> productStandardPrices,
        List<Decimal> productSpecialPrices
    ) {
        List<SObject> unrelatedSObjects = new List<SObject>();
        Account account = factory.createAccount(accountName);
        unrelatedSObjects.add(account);
        Pricebook2 pricebook = factory.createPricebook(pricebookName);
        unrelatedSObjects.add(pricebook);
        List<Product2> products = factory.createProducts(productNames);
        unrelatedSObjects.addAll(products);

        insert unrelatedSObjects;

        Contract contract = factory.createContract(account.Id, pricebook.Id);
        insert contract;

        Order order = factory.createOrder(
            account.Id,
            contract.Id,
            pricebook.Id
        );
        insert order;

        unrelatedSObjects.clear();

        List<PricebookEntry> standardPricebookEntries = factory.createPricebookEntries(
            Test.getStandardPricebookId(),
            products,
            productStandardPrices
        );
        unrelatedSObjects.addAll(standardPricebookEntries);
        List<PricebookEntry> specialPricebookEntries = factory.createPricebookEntries(
            pricebook.Id,
            products,
            productSpecialPrices
        );
        unrelatedSObjects.addAll(specialPricebookEntries);
        insert unrelatedSObjects;

        List<OrderItem> orderItems = factory.createOrderItems(
            order.Id,
            new List<PricebookEntry>{
                specialPricebookEntries.get(0),
                specialPricebookEntries.get(1)
            }
        );
        insert orderItems;
    }
}
