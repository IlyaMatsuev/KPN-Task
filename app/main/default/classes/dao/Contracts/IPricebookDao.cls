/**
 * Created by Ilya Matsuev on 2/26/2021.
 */

public interface IPricebookDao {
    Map<Id, PricebookEntry> getEntriesByPricebookOrEntriesIdLike(
        Id pricebookId,
        Set<Id> pricebookEntriesIds,
        String productNameSearchTerm
    );
}
