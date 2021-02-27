/**
 * Created by Ilya Matsuev on 2/25/2021.
 */

public with sharing class PricebookDao implements IPricebookDao {
    public List<PricebookEntry> getEntriesByPricebookOrEntriesIdLike(
        Id pricebookId,
        Set<Id> pricebookEntriesIds,
        String productNameSearchTerm
    ) {
        if (String.isBlank(productNameSearchTerm)) {
            productNameSearchTerm = '';
        }
        String likeClause = '%' + productNameSearchTerm + '%';
        return [
            SELECT UnitPrice, Product2.Id, Product2.Name
            FROM PricebookEntry
            WHERE
                (Pricebook2Id = :pricebookId
                OR Id IN :pricebookEntriesIds)
                AND Product2.Name LIKE :likeClause
        ];
    }

    public List<PricebookEntry> getEntriesByPricebookAndProductIds(
        Id pricebookId,
        Set<Id> productIds
    ) {
        return [
            SELECT UnitPrice, Product2Id, Product2.Name
            FROM PricebookEntry
            WHERE Product2Id IN :productIds AND Pricebook2Id = :pricebookId
        ];
    }
}
