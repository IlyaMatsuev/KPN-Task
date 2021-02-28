/**
 * Created by Ilya Matsuev on 3/1/2021.
 */

public with sharing class OrderWebServiceMock implements HttpCalloutMock {
    private final String SUCCESS_RESPONSE_MESSAGE = 'Request Caught';
    private final String FAILURE_RESPONSE_MESSAGE = 'Request Failed';

    public HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();

        try {
            OrderWebServiceRequest requestWrapper = parseRequest(
                request.getBody()
            );

            // Just to imitate logic somehow
            if (requestWrapper.orderProducts.isEmpty()) {
                throw new ListException('Order cannot be without products');
            }

            response.setStatusCode(HttpHelper.SUCCESS_STATUS);
            response.setBody(SUCCESS_RESPONSE_MESSAGE);
        } catch (Exception error) {
            response.setStatusCode(HttpHelper.CLIENT_FAILURE_STATUS);
            response.setBody(FAILURE_RESPONSE_MESSAGE);
        }

        return response;
    }

    private OrderWebServiceRequest parseRequest(String body) {
        return (OrderWebServiceRequest) JSON.deserialize(
            body,
            OrderWebServiceRequest.class
        );
    }
}
