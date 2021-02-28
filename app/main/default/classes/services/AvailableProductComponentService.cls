/**
 * Created by Ilya Matsuev on 2/27/2021.
 */

public with sharing class AvailableProductComponentService extends OrderService implements IAvailableProductComponentService {
    public final static Decimal INIT_QUANTITY_AMOUNT = 1;

    private final static String ORDER_LOCKED_ERROR_CODE = 'ENTITY_IS_LOCKED';

    private final IPricebookDao pricebookDao = new PricebookDao();

    public List<ProductWrapper> getAvailableProducts(
        Order order,
        String productNameSearchTerm
    ) {
        try {
            Set<Id> pricebookEntriesIdsAssignedToOrder = CollectionUtils.getIdFieldFromList(
                order.OrderItems,
                'PricebookEntryId'
            );

            List<PricebookEntry> pricebookEntries = pricebookDao.getEntriesByPricebookOrEntriesIdLike(
                order.Pricebook2Id,
                pricebookEntriesIdsAssignedToOrder,
                productNameSearchTerm
            );

            List<ProductWrapper> products = new List<ProductWrapper>();

            for (PricebookEntry pricebookEntry : pricebookEntries) {
                products.add(
                    new ProductWrapper(
                        pricebookEntry.Product2.Id,
                        pricebookEntry.Product2.Name,
                        pricebookEntry.UnitPrice,
                        pricebookEntriesIdsAssignedToOrder.contains(
                            pricebookEntry.Id
                        )
                    )
                );
            }

            return products;
        } catch (Exception error) {
            throw new AvailableProductComponentException(
                Label.UnexpectedErrorMessage
            );
        }
    }

    public List<ProductWrapper> addProducts(
        Order order,
        List<ProductWrapper> products
    ) {
        try {
            Map<Boolean, Map<Id, ProductWrapper>> assignedAndUnassignedProducts = getAssignedAndUnassignedProducts(
                products
            );

            List<OrderItem> orderItemsToUpsert = new List<OrderItem>();

            orderItemsToUpsert.addAll(
                getIncreasedOrderItems(
                    order.OrderItems,
                    assignedAndUnassignedProducts.get(true).keySet()
                )
            );

            orderItemsToUpsert.addAll(
                getNewOrderItems(
                    order,
                    assignedAndUnassignedProducts.get(false)
                )
            );

            orderDao.upsertOrderItems(orderItemsToUpsert);

            return products;
        } catch (DmlException error) {
            if (error.getMessage().contains(ORDER_LOCKED_ERROR_CODE)) {
                throw new AvailableProductComponentException(
                    Label.OrderLockedErrorMessage
                );
            }
            throw new AvailableProductComponentException(
                error.getDmlMessage(0)
            );
        } catch (Exception error) {
            throw new AvailableProductComponentException(
                Label.UnexpectedErrorMessage
            );
        }
    }

    private Map<Boolean, Map<Id, ProductWrapper>> getAssignedAndUnassignedProducts(
        List<ProductWrapper> products
    ) {
        Map<Id, ProductWrapper> assignedProducts = new Map<Id, ProductWrapper>();
        Map<Id, ProductWrapper> unassignedProducts = new Map<Id, ProductWrapper>();

        for (ProductWrapper product : products) {
            if (product.assignedToOrder) {
                assignedProducts.put(product.id, product);
            } else {
                unassignedProducts.put(product.id, product);
            }
        }
        return new Map<Boolean, Map<Id, ProductWrapper>>{
            true => assignedProducts,
            false => unassignedProducts
        };
    }

    private List<OrderItem> getIncreasedOrderItems(
        List<OrderItem> items,
        Set<Id> assignedProductsIds
    ) {
        List<OrderItem> increasedOrderItems = new List<OrderItem>();

        for (OrderItem orderItem : items) {
            if (assignedProductsIds.contains(orderItem.Product2.Id)) {
                orderItem.Quantity++;
                increasedOrderItems.add(orderItem);
            }
        }
        return increasedOrderItems;
    }

    private List<OrderItem> getNewOrderItems(
        Order order,
        Map<Id, ProductWrapper> unassignedProducts
    ) {
        List<PricebookEntry> pricebookEntries = pricebookDao.getEntriesByPricebookAndProductIds(
            order.Pricebook2Id,
            unassignedProducts.keySet()
        );

        Map<Id, PricebookEntry> pricebookEntriesByProductIds = new Map<Id, PricebookEntry>();

        for (PricebookEntry pricebookEntry : pricebookEntries) {
            pricebookEntriesByProductIds.put(
                pricebookEntry.Product2Id,
                pricebookEntry
            );
        }

        List<OrderItem> newOrderItems = new List<OrderItem>();

        for (ProductWrapper product : unassignedProducts.values()) {
            newOrderItems.add(
                new OrderItem(
                    OrderId = order.Id,
                    Product2Id = product.id,
                    PricebookEntryId = pricebookEntriesByProductIds.get(
                            product.id
                        )
                        .Id,
                    Quantity = INIT_QUANTITY_AMOUNT,
                    UnitPrice = product.listPrice,
                    ListPrice = product.listPrice
                )
            );
            product.assignedToOrder = true;
        }
        return newOrderItems;
    }
}
