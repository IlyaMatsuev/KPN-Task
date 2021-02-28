/**
 * Created by Ilya Matsuev on 2/27/2021.
 */

public virtual with sharing class OrderService implements IOrderService {
    protected final IOrderDao orderDao = new OrderDao();

    protected final IOrderWebService orderWebService = new OrderWebService();

    public virtual Order getOrder(Id orderId) {
        return orderDao.getById(orderId);
    }
}
