/**
 * Created by Ilya Matsuev on 2/26/2021.
 */

public interface IPricebookDao {
    List<PricebookEntry> getEntriesByPricebookOrEntriesIdLike(
        Id pricebookId,
        Set<Id> pricebookEntriesIds,
        String productNameSearchTerm
    );
    List<PricebookEntry> getEntriesByPricebookAndProductIds(
        Id pricebookId,
        Set<Id> productIds
    );
}
