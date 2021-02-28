/**
 * Created by Ilya Matsuev on 2/28/2021.
 */

@IsTest
public with sharing class OrderProductCmpControllerTest {
    private final static String ACCOUNT_NAME = 'Microsoft';
    private final static String PRICEBOOK_NAME = 'Weekend Prices';
    private final static List<String> PRODUCT_NAMES = new List<String>{
        'Macbook Pro M1',
        'Macbook Pro 16',
        'IPhone 12',
        'IPhone X'
    };
    private final static List<Decimal> STANDARD_PRODUCT_PRICES = new List<Decimal>{
        3800,
        3200,
        950,
        700
    };
    private final static List<Decimal> SPECIAL_PRODUCT_PRICES = new List<Decimal>{
        3500,
        3000,
        900,
        600
    };

    @TestSetup
    public static void setup() {
        ITestDataFactoryFacade facade = new TestDataFactoryFacade(
            new OrderCmpTestDataFactory()
        );
        facade.setup(
            ACCOUNT_NAME,
            PRICEBOOK_NAME,
            PRODUCT_NAMES,
            STANDARD_PRODUCT_PRICES,
            SPECIAL_PRODUCT_PRICES
        );
    }

    @IsTest
    public static void getOrderedProductsPositiveTest() {
        Order order = getOrder();
        List<OrderItem> orderItems = order.OrderItems;

        List<ProductWrapper> products = OrderProductComponentController.getOrderedProducts(
            order.Id
        );

        System.assertNotEquals(null, products);
        System.assertEquals(orderItems.size(), products.size());

        for (ProductWrapper product : products) {
            System.assertNotEquals(null, product);
            System.assert(product.assignedToOrder);
        }
    }

    @IsTest
    public static void activateOrderPositiveTest() {
        Order order = getOrder();
        Contract contract = order.Contract;
        contract.Status = 'Activated';
        update contract;

        Test.setMock(HttpCalloutMock.class, new OrderWebServiceMock());

        System.assertEquals('Draft', order.Status);

        Test.startTest();
        Order actualOrder = OrderProductComponentController.activateOrder(
            order.Id
        );
        Test.stopTest();

        System.assertNotEquals(null, order);
        System.assertEquals(order.Id, actualOrder.Id);
        System.assertEquals('Activated', actualOrder.Status);
    }

    private static Order getOrder() {
        return [
            SELECT
                Pricebook2Id,
                Status,
                Contract.Id,
                Contract.Status,
                (SELECT Id, Product2Id FROM OrderItems)
            FROM Order
        ];
    }
}
