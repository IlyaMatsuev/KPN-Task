/**
 * Created by Ilya Matsuev on 2/28/2021.
 */

public with sharing class OrderWebService implements IOrderWebService {
    public void activate(Order order) {
        IRestClient client = new RestClient(Label.OrderWebServiceEndpoint);

        List<OrderProductWebServiceRequest> orderProducts = new List<OrderProductWebServiceRequest>();

        for (OrderItem orderItem : order.OrderItems) {
            orderProducts.add(
                new OrderProductWebServiceRequest(
                    orderItem.Product2.Name,
                    orderItem.Product2.ProductCode,
                    orderItem.UnitPrice,
                    orderItem.Quantity
                )
            );
        }

        OrderWebServiceRequest request = new OrderWebServiceRequest(
            order.Account.AccountNumber,
            order.OrderNumber,
            order.Type,
            'Activated',
            orderProducts
        );

        RestResponse response;
        try {
            response = client
                .withMethod(HttpMethod.POST)
                .withHeader(
                    HttpHelper.CONTENT_TYPE_HEADER,
                    HttpHelper.CONTENT_TYPE_JSON
                )
                .withBody(JSON.serialize(request))
                .send();
        } catch (CalloutException error) {
            error.setMessage(Label.OrderWebServiceUnexpectedErrorMessage);
            throw error;
        }

        if (!response.success) {
            throw new CalloutException(
                Label.OrderActivationResponseErrorMessage
            );
        }
    }

    public void activateAsync(Order order) {
        activate(JSON.serialize(order));
    }

    @Future(Callout=true)
    private static void activate(String orderJson) {
        IOrderWebService service = new OrderWebService();
        service.activate((Order) JSON.deserialize(orderJson, Order.class));
    }
}
