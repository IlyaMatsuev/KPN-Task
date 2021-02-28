/**
 * Created by Ilya Matsuev on 2/28/2021.
 */

public with sharing class RestResponse {
    private HttpResponse response { get; set; }

    public Boolean success {
        get {
            return response.getStatusCode() == HttpHelper.SUCCESS_STATUS;
        }
    }

    public RestResponse(HttpResponse response) {
        this.response = response;
    }
}
