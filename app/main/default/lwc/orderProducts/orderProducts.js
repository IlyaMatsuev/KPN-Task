/**
 * Created by Ilya Matsuev on 2/27/2021.
 */

import { LightningElement, track, api, wire } from 'lwc';
import getOrderedProducts from '@salesforce/apex/OrderProductComponentController.getOrderedProducts';
import activateOrder from '@salesforce/apex/OrderProductComponentController.activateOrder';
import { refreshApex } from '@salesforce/apex';
import { getRecordNotifyChange } from 'lightning/uiRecordApi';
import { registerListener, unregisterAllListeners } from 'c/pubsub';
import { CurrentPageReference } from 'lightning/navigation';
import { controlConfig, tableConfig, component } from './config';

export default class OrderProducts extends LightningElement {
    @api recordId;
    @api title = component.title;
    @api icon = component.icon;
    @api noDataMessage = component.noDataMessage;

    @track loading = true;

    @track controlsConfig = {
        ...controlConfig,
        button: {
            ...controlConfig.button,
            onClick: this.onActivateOrder.bind(this)
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

    @wire(getOrderedProducts, { orderId: '$recordId' })
    fetchProducts(result) {
        this.fetchProductsResult = result;
        const { data, error } = result;
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

    connectedCallback() {
        registerListener(
            'refreshView',
            () => refreshApex(this.fetchProductsResult),
            this
        );
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
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

    onActivateOrder() {
        this.loading = true;
        activateOrder({ orderId: this.recordId })
            .then((order) => this.handleOrderActivation(order))
            .catch((error) => this.handleError(error));
    }

    handleOrderActivation() {
        this.genericTemplate.notify('Order was successfully activated');
        getRecordNotifyChange([{ recordId: this.recordId }]);
        this.loading = false;
    }

    handleError(error) {
        this.genericTemplate.notify(error.body.message, 'error');
        this.loading = false;
    }

    sort(data, field, direction) {
        const isAscending = direction === 'asc' ? 1 : -1;

        return [...data].sort((x, y) => {
            x = x[field] ? x[field] : '';
            y = y[field] ? y[field] : '';
            return isAscending * ((x > y) - (y > x));
        });
    }
}
