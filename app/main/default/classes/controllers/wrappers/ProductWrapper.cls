/**
 * Created by Ilya Matsuev on 2/26/2021.
 */

public inherited sharing class ProductWrapper {
    @AuraEnabled
    public Id id { get; set; }

    @AuraEnabled
    public String name { get; set; }

    @AuraEnabled
    public Decimal listPrice { get; set; }

    @AuraEnabled
    public Decimal unitPrice { get; set; }

    @AuraEnabled
    public Decimal totalPrice { get; set; }

    @AuraEnabled
    public Decimal quantity { get; set; }

    @AuraEnabled
    public Boolean assignedToOrder { get; set; }

    public ProductWrapper(
        Id id,
        String name,
        Decimal listPrice,
        Boolean assignedToOrder
    ) {
        this.id = id;
        this.name = name;
        this.listPrice = listPrice;
        this.assignedToOrder = assignedToOrder;
    }

    public ProductWrapper(
        Id id,
        String name,
        Decimal unitPrice,
        Decimal quantity,
        Decimal totalPrice
    ) {
        this.id = id;
        this.name = name;
        this.unitPrice = unitPrice;
        this.totalPrice = totalPrice;
        this.quantity = quantity;
        this.assignedToOrder = true;
    }
}
