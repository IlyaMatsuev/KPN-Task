/**
 * Created by Ilya Matsuev on 2/28/2021.
 */

public with sharing class RestClient implements IRestClient {
    private final Integer DEFAULT_TIMEOUT = 12000;

    private HttpRequest request = new HttpRequest();

    public RestClient(String endpoint) {
        toEndpoint(endpoint);
    }

    public IRestClient toEndpoint(String endpoint) {
        request.setEndpoint(endpoint);
        return this;
    }

    public IRestClient withMethod(HttpMethod method) {
        request.setMethod(String.valueOf(method).toUpperCase());
        return this;
    }

    public IRestClient withQueryParam(String name, String value) {
        return withQueryParams(new Map<String, String>{ name => value });
    }

    public IRestClient withQueryParams(Map<String, String> queryParams) {
        if (!queryParams?.isEmpty()) {
            String completeEndpoint = request.getEndpoint();
            List<String> pairs = new List<String>();
            completeEndpoint += '?';
            for (String name : queryParams.keySet()) {
                pairs.add(name + '=' + queryParams.get(name));
            }
            request.setEndpoint(completeEndpoint + String.join(pairs, '&'));
        }
        return this;
    }

    public IRestClient withHeader(String name, String value) {
        return withHeaders(new Map<String, String>{ name => value });
    }

    public IRestClient withHeaders(Map<String, String> headers) {
        if (!headers?.isEmpty()) {
            for (String name : headers.keySet()) {
                request.setHeader(name, headers.get(name));
            }
        }
        return this;
    }

    public IRestClient withBody(String body) {
        request.setBody(body);
        return this;
    }

    public RestResponse send() {
        request.setTimeout(DEFAULT_TIMEOUT);
        return new RestResponse(new Http().send(request));
    }
}
