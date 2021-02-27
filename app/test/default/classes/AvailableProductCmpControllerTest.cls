/**
 * Created by Ilya Matsuev on 2/27/2021.
 */

@IsTest
private class AvailableProductCmpControllerTest {
    private final static IAvailableProductCmpTestDataFactory factory = new AvailableProductCmpTestDataFactory();

    private final static String ACCOUNT_NAME = 'Apple';
    private final static String PRICEBOOK_NAME = 'Special Prices';
    private final static List<String> PRODUCT_NAMES = new List<String>{
        'Macbook Pro 16',
        'Macbook Pro 15',
        'Macbook Pro 13',
        'IPhone 12'
    };
    private final static List<Decimal> STANDARD_PRODUCT_PRICES = new List<Decimal>{
        3800,
        2200,
        1900,
        950
    };
    private final static List<Decimal> SPECIAL_PRODUCT_PRICES = new List<Decimal>{
        3500,
        2000,
        1500,
        800
    };

    @TestSetup
    public static void setup() {
        List<SObject> unrelatedSObjects = new List<SObject>();
        Account account = factory.createAccount(ACCOUNT_NAME);
        unrelatedSObjects.add(account);
        Pricebook2 pricebook = factory.createPricebook(PRICEBOOK_NAME);
        unrelatedSObjects.add(pricebook);
        List<Product2> products = factory.createProducts(PRODUCT_NAMES);
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
            STANDARD_PRODUCT_PRICES
        );
        unrelatedSObjects.addAll(standardPricebookEntries);
        List<PricebookEntry> specialPricebookEntries = factory.createPricebookEntries(
            pricebook.Id,
            products,
            SPECIAL_PRODUCT_PRICES
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

    @IsTest
    public static void getAvailableProductsNoSearchCriteriaPositiveTest() {
        Order order = getOrder();
        String productNameSearchTerm = '';
        List<PricebookEntry> assignedPricebookEntries = getPricebookEntries(
            order.Pricebook2Id,
            new Set<String>{ PRODUCT_NAMES.get(0), PRODUCT_NAMES.get(1) }
        );

        List<ProductWrapper> products = AvailableProductComponentController.getAvailableProducts(
            order.Id,
            productNameSearchTerm
        );

        System.assertNotEquals(null, products);
        System.assertEquals(PRODUCT_NAMES.size(), products.size());

        List<ProductWrapper> assignedProducts = new List<ProductWrapper>();
        List<ProductWrapper> unassignedProducts = new List<ProductWrapper>();
        for (ProductWrapper product : products) {
            if (product.assignedToOrder) {
                assignedProducts.add(product);
            } else {
                unassignedProducts.add(product);
            }
        }

        System.assertEquals(
            assignedPricebookEntries.size(),
            assignedProducts.size()
        );
        System.assertEquals(
            PRODUCT_NAMES.size() - assignedPricebookEntries.size(),
            unassignedProducts.size()
        );
    }

    @IsTest
    public static void addProductsPositiveTest() {
        Order order = getOrder();
        String assignedProductName = 'Macbook Pro 15';
        String unassignedProductName = 'Macbook Pro 13';

        List<PricebookEntry> assignedAndUnassignedPricebookEntries = getPricebookEntries(
            order.Pricebook2Id,
            // Getting 2 and 3 elements from all products (one already assigned and one not)
            new Set<String>{ assignedProductName, unassignedProductName }
        );
        List<ProductWrapper> newProducts = new List<ProductWrapper>();
        for (
            PricebookEntry pricebookEntry : assignedAndUnassignedPricebookEntries
        ) {
            newProducts.add(
                new ProductWrapper(
                    pricebookEntry.Product2Id,
                    pricebookEntry.Product2.Name,
                    pricebookEntry.UnitPrice,
                    pricebookEntry.Product2.Name == assignedProductName
                )
            );
        }

        List<ProductWrapper> products = AvailableProductComponentController.addProducts(
            order.Id,
            JSON.serialize(newProducts)
        );

        System.assertNotEquals(null, products);
        System.assertEquals(newProducts.size(), products.size());

        for (ProductWrapper product : products) {
            System.assertNotEquals(null, product);
            System.assert(product.assignedToOrder);
        }

        List<OrderItem> actualOrderItems = getOrderItems(order.Id);
        // 2 assigned order items + one new that we've just assigned
        System.assertEquals(3, actualOrderItems.size());

        for (OrderItem orderItem : actualOrderItems) {
            Decimal expectedQuantity = AvailableProductComponentService.INIT_QUANTITY_AMOUNT;
            if (orderItem.Product2.Name == assignedProductName) {
                expectedQuantity++;
            }
            System.assertEquals(expectedQuantity, orderItem.Quantity);
        }
    }

    private static Order getOrder() {
        return [SELECT Pricebook2Id FROM Order];
    }

    private static List<PricebookEntry> getPricebookEntries(
        Id pricebookId,
        Set<String> productNames
    ) {
        return [
            SELECT Product2Id, Product2.Name, UnitPrice
            FROM PricebookEntry
            WHERE Pricebook2Id = :pricebookId AND Product2.Name IN :productNames
        ];
    }

    private static List<OrderItem> getOrderItems(Id orderId) {
        return [
            SELECT Quantity, UnitPrice, Product2.Name
            FROM OrderItem
            WHERE OrderId = :orderId
        ];
    }
}
