/**
 * Created by Ilya Matsuev on 2/25/2021.
 */

const component = {
    title: 'Available Products',
    icon: 'standard:product',
    noDataMessage: 'Sorry, there is nothing to show you!'
};

const controlConfig = {
    enableControls: true,
    button: {
        label: 'Add Products'
    },
    search: {
        searchTerm: ''
    }
};

const tableConfig = {
    hideCheckboxes: false,
    sortBy: 'listPrice',
    sortDirection: 'desc',
    sortByPrioritized: 'assignedToOrder',
    data: [],
    columns: [
        {
            label: 'Product name',
            fieldName: 'name',
            type: 'text',
            sortable: true
        },
        {
            label: 'List Price',
            fieldName: 'listPrice',
            type: 'number',
            sortable: true
        }
    ]
};

export { component, controlConfig, tableConfig };
