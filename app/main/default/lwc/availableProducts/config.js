/**
 * Created by Ilya Matsuev on 2/25/2021.
 */

const columns = [
    { label: 'Product name', fieldName: 'name', type: 'text', sortable: true },
    {
        label: 'List Price',
        fieldName: 'listPrice',
        type: 'number',
        sortable: true
    }
];

const sorting = {
    sortBy: 'listPrice',
    sortByPrioritized: 'attachedToOrder',
    sortDirection: 'desc'
};

export { columns, sorting };
