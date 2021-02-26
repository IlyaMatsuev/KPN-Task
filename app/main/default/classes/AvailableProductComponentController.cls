/**
 * Created by Ilya Matsuev on 2/25/2021.
 */

public with sharing class AvailableProductComponentController {
  private static IOrderDao orderDao = new OrderDao();
  private static IPricebookDao pricebookDao = new PricebookDao();

  @AuraEnabled(Cacheable=true)
  public static List<ProductWrapper> getAvailableProducts(
    Id orderId,
    String productNameSearchTerm
  ) {
    Order order = orderDao.getById(orderId);
    Set<Id> pricebookEntriesAttachedToOrder = CollectionUtils.getIdFieldFromList(
      order.OrderItems,
      'PricebookEntryId'
    );

    List<ProductWrapper> products = new List<ProductWrapper>();

    Map<Id, PricebookEntry> pricebookEntries = pricebookDao.getEntriesByPricebookOrEntriesIdLike(
      order.Pricebook2Id,
      pricebookEntriesAttachedToOrder,
      productNameSearchTerm
    );

    for (PricebookEntry pricebookEntry : pricebookEntries.values()) {
      products.add(
        new ProductWrapper(
          pricebookEntry.Product2.Id,
          pricebookEntry.Product2.Name,
          pricebookEntry.UnitPrice,
          pricebookEntriesAttachedToOrder.contains(pricebookEntry.Id)
        )
      );
    }

    return products;
  }

  public inherited sharing class ProductWrapper implements Comparable {
    @AuraEnabled
    public Id id { get; private set; }

    @AuraEnabled
    public String name { get; private set; }

    @AuraEnabled
    public Decimal listPrice { get; private set; }

    @AuraEnabled
    public Boolean attachedToOrder { get; private set; }

    public ProductWrapper(
      Id id,
      String name,
      Decimal listPrice,
      Boolean attachedToOrder
    ) {
      this.id = id;
      this.name = name;
      this.listPrice = listPrice;
      this.attachedToOrder = attachedToOrder;
    }

    // TODO: not needed anymore
    public Integer compareTo(Object toCompare) {
      ProductWrapper anotherProductWrapper = (ProductWrapper) toCompare;

      if (!this.attachedToOrder && anotherProductWrapper.attachedToOrder) {
        return 1;
      } else if (
        this.attachedToOrder && !anotherProductWrapper.attachedToOrder
      ) {
        return -1;
      } else {
        return 0;
      }
    }
  }
}
