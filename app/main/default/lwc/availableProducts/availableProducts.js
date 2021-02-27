/**
 * Created by Ilya Matsuev on 2/25/2021.
 */

import { LightningElement, track, api, wire } from 'lwc';
import getAvailableProducts from '@salesforce/apex/AvailableProductComponentController.getAvailableProducts';
import addProducts from '@salesforce/apex/AvailableProductComponentController.addProducts';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { columns, sorting, component } from './config';

export default class AvailableProducts extends LightningElement {
    @api recordId;
    @api title = component.title;
    @api icon = component.icon;
    @api noDataMessage = component.noDataMessage;
    @track loading = true;
    @track data;
    @track columns = columns;
    @track sortBy = sorting.sortBy;
    @track sortDirection = sorting.sortDirection;
    @track sortByPrioritized = sorting.sortByPrioritized;
    @track searchTerm = '';

    get haveData() {
        return this.data && this.data.length > 0;
    }

    @wire(getAvailableProducts, {
        orderId: '$recordId',
        productNameSearchTerm: '$searchTerm'
    })
    fetchProducts({ data = [], error }) {
        if (!error && !data) {
            this.loading = true;
        } else {
            if (error) {
                this.notify(error.body.message, 'error');
            }
            this.data = this.sort(data);
            this.loading = false;
        }
    }

    onProductsSort({ detail }) {
        this.sortBy = detail.fieldName;
        this.sortDirection = detail.sortDirection;

        this.data = this.sort(this.data);
    }

    onProductSearch({ target }) {
        this.loading = true;
        this.searchTerm = target.value;
    }

    onAddProducts() {
        const datatable = this.template.querySelector('.products-table');
        const selectedProducts = datatable.getSelectedRows();
        if (selectedProducts && selectedProducts.length > 0) {
            this.loading = true;
            addProducts({
                orderId: this.recordId,
                serializedProducts: JSON.stringify(selectedProducts)
            })
                .then((addedProducts) =>
                    this.handleProductsAdded(addedProducts)
                )
                .catch((error) => this.handleError(error));
        }
    }

    handleProductsAdded(addedProducts) {
        this.data = this.sort(
            // Replacing this.data with the updated records
            this.data.map(
                (pr) => addedProducts.find((p) => p.id === pr.id) || pr
            )
        );
        this.loading = false;
        this.refreshView();
        this.notify('Products were successfully added to the order');
    }

    handleError(error) {
        this.loading = false;
        this.notify(error.body.message, 'error');
    }

    sort(
        data,
        field = this.sortBy,
        priorityField = this.sortByPrioritized,
        direction = this.sortDirection
    ) {
        const prioritizedData = data.filter((d) => d[priorityField]);
        const otherData = data.filter((d) => !d[priorityField]);

        const isAscending = direction === 'asc' ? 1 : -1;

        const sortingCallback = (x, y) => {
            x = x[field] ? x[field] : '';
            y = y[field] ? y[field] : '';
            return isAscending * ((x > y) - (y > x));
        };

        prioritizedData.sort(sortingCallback);
        otherData.sort(sortingCallback);

        return prioritizedData.concat(otherData);
    }

    notify(message, variant = 'success') {
        console.log(message);
        this.dispatchEvent(
            new ShowToastEvent({
                title: variant === 'success' ? 'Success!' : 'Error!',
                message,
                variant,
                mode: 'pester'
            })
        );
    }

    refreshView() {
        // I could utilize getRecordNotifyChange method which came in Winter 21 but it has one disadvantage:
        // - It will not update order related list if I create a new order item fot the order.
        // This method can only update view for the records that were already presented
        // Also, I could wrap this lwc component into an aura component and handle an event to call force:refreshView
        // But I found this trick below much easier
        // eslint-disable-next-line no-eval
        eval('$A.get("e.force:refreshView").fire();');
    }
}
