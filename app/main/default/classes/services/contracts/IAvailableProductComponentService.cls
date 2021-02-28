/**
 * Created by Ilya Matsuev on 2/27/2021.
 */

public interface IAvailableProductComponentService extends IOrderService {
    List<ProductWrapper> getAvailableProducts(
        Order order,
        String productNameSearchTerm
    );

    List<ProductWrapper> addProducts(
        Order order,
        List<ProductWrapper> products
    );
}
