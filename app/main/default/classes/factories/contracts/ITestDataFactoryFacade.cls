/**
 * Created by Ilya Matsuev on 2/28/2021.
 */

public interface ITestDataFactoryFacade {
    void setup(
        String accountName,
        String pricebookName,
        List<String> productNames,
        List<Decimal> productStandardPrices,
        List<Decimal> productSpecialPrices
    );
}
