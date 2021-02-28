/**
 * Created by Ilya Matsuev on 2/28/2021.
 */

public with sharing class OrderWebServiceRequest {
    public String accountNumber { get; set; }
    public String orderNumber { get; set; }
    public String type { get; set; }
    public String status { get; set; }
    public List<OrderProductWebServiceRequest> orderProducts { get; set; }

    public OrderWebServiceRequest(
        String accountNumber,
        String orderNumber,
        String type,
        String status,
        List<OrderProductWebServiceRequest> orderProducts
    ) {
        this.accountNumber = accountNumber;
        this.orderNumber = orderNumber;
        this.type = type;
        this.status = status;
        this.orderProducts = orderProducts;
    }
}
