/**
 * Created by Ilya Matsuev on 2/27/2021.
 */

const component = {
    title: 'Order Products',
    icon: 'standard:product_item',
    noDataMessage: 'Sorry, there is nothing to show you!'
};

const controlConfig = {
    enableControls: true,
    button: {
        label: 'Activate'
    }
};

const tableConfig = {
    hideCheckboxes: true,
    sortBy: 'totalPrice',
    sortDirection: 'desc',
    data: [],
    columns: [
        {
            label: 'Product name',
            fieldName: 'name',
            type: 'text',
            sortable: true
        },
        {
            label: 'Unit Price',
            fieldName: 'unitPrice',
            type: 'number',
            sortable: true
        },
        {
            label: 'Quantity',
            fieldName: 'quantity',
            type: 'number',
            sortable: true
        },
        {
            label: 'Total Price',
            fieldName: 'totalPrice',
            type: 'number',
            sortable: true
        }
    ]
};

export { controlConfig, tableConfig, component };
