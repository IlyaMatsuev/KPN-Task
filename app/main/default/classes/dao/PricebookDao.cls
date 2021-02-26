/**
 * Created by Ilya Matsuev on 2/25/2021.
 */

public with sharing class PricebookDao implements IPricebookDao {
  public Map<Id, PricebookEntry> getEntriesByPricebookOrEntriesIdLike(
    Id pricebookId,
    Set<Id> pricebookEntriesIds,
    String productNameSearchTerm
  ) {
    if (String.isBlank(productNameSearchTerm)) {
      productNameSearchTerm = '';
    }
    String likeClause = '%' + productNameSearchTerm + '%';
    return new Map<Id, PricebookEntry>(
      [
        SELECT UnitPrice, Product2.Id, Product2.Name
        FROM PricebookEntry
        WHERE
          (Pricebook2Id = :pricebookId
          OR Id IN :pricebookEntriesIds)
          AND Product2.Name LIKE :likeClause
      ]
    );
  }
}
