/**
 * Created by Ilya Matsuev on 2/25/2021.
 */

import { LightningElement, track, api, wire } from 'lwc';
import getAvailableProducts from '@salesforce/apex/AvailableProductComponentController.getAvailableProducts';
import addProducts from '@salesforce/apex/AvailableProductComponentController.addProducts';
import { fireEvent } from 'c/pubsub';
import { component, controlConfig, tableConfig } from './config';
import { CurrentPageReference } from 'lightning/navigation';

export default class AvailableProducts extends LightningElement {
    @api recordId;
    @api title = component.title;
    @api icon = component.icon;
    @api noDataMessage = component.noDataMessage;
    @track loading = true;

    @track controlsConfig = {
        ...controlConfig,
        button: {
            ...controlConfig.button,
            onClick: this.onAddProducts.bind(this)
        },
        search: {
            ...controlConfig.search,
            onSearch: this.onProductSearch.bind(this)
        }
    };

    @track tableConfig = {
        ...tableConfig,
        onSort: this.onProductsSort.bind(this)
    };

    get genericTemplate() {
        return this.template.querySelector('.generic-template');
    }

    @wire(CurrentPageReference) pageRef;

    @wire(getAvailableProducts, {
        orderId: '$recordId',
        productNameSearchTerm: '$controlsConfig.search.searchTerm'
    })
    fetchProducts({ data, error }) {
        if (!error && !data) {
            this.loading = true;
        } else if (error) {
            this.handleError(error);
        } else {
            this.tableConfig.data =
                this.sort(
                    data,
                    this.tableConfig.sortBy,
                    this.tableConfig.sortDirection
                ) || [];
            this.loading = false;
        }
    }

    onProductsSort({ detail }) {
        this.tableConfig = {
            ...this.tableConfig,
            data: this.sort(
                this.tableConfig.data,
                detail.fieldName,
                detail.sortDirection
            ),
            sortBy: detail.fieldName,
            sortDirection: detail.sortDirection
        };
    }

    onProductSearch({ target }) {
        this.loading = true;
        this.controlsConfig.search.searchTerm = target.value;
    }

    onAddProducts() {
        const datatable = this.genericTemplate.table;
        const selectedProducts = datatable.getSelectedRows();
        if (selectedProducts && selectedProducts.length > 0) {
            this.loading = true;
            addProducts({
                orderId: this.recordId,
                serializedProducts: JSON.stringify(selectedProducts)
            })
                .then((products) => this.handleProductsAdded(products))
                .catch((error) => this.handleError(error));
        }
    }

    handleProductsAdded(addedProducts) {
        this.tableConfig.data = this.sort(
            // Replacing data array with the updated records
            this.tableConfig.data.map(
                (pr) => addedProducts.find((p) => p.id === pr.id) || pr
            ),
            this.tableConfig.sortBy,
            this.tableConfig.sortDirection
        );
        this.refreshView();
        this.genericTemplate.notify(
            'Products were successfully added to the order'
        );
        this.loading = false;
    }

    handleError(error) {
        this.genericTemplate.notify(error.body.message, 'error');
        this.loading = false;
    }

    sort(data, field, direction) {
        const prioritizedData = data.filter(
            (d) => d[this.tableConfig.sortByPrioritized]
        );
        const otherData = data.filter(
            (d) => !d[this.tableConfig.sortByPrioritized]
        );

        const isAscending = direction === 'asc' ? 1 : -1;

        const sortingCallback = (x, y) => {
            x = x[field] ? x[field] : '';
            y = y[field] ? y[field] : '';
            return isAscending * ((x > y) - (y > x));
        };

        return prioritizedData
            .sort(sortingCallback)
            .concat(otherData.sort(sortingCallback));
    }

    refreshView() {
        // Line below is needed to refresh standard order related list
        // eslint-disable-next-line no-eval
        eval('$A.get("e.force:refreshView").fire();');
        // This is needed for other custom components
        fireEvent(this.pageRef, 'refreshView', {});
    }
}
