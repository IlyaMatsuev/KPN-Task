/**
 * Created by Ilya Matsuev on 2/28/2021.
 */

public with sharing class OrderProductWebServiceRequest {
    public String name { get; set; }
    public String code { get; set; }
    public Decimal unitPrice { get; set; }
    public Decimal quantity { get; set; }

    public OrderProductWebServiceRequest(
        String name,
        String code,
        Decimal unitPrice,
        Decimal quantity
    ) {
        this.name = name;
        this.code = code;
        this.unitPrice = unitPrice;
        this.quantity = quantity;
    }
}
