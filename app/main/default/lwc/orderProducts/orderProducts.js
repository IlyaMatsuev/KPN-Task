/**
 * Created by Ilya Matsuev on 2/27/2021.
 */

import { LightningElement, track, api, wire } from 'lwc';
import getOrderedProducts from '@salesforce/apex/OrderProductComponentController.getOrderedProducts';
import { refreshApex } from '@salesforce/apex';
import { registerListener, unregisterAllListeners } from 'c/pubsub';
import { controlConfig, tableConfig, component } from './config';
import { CurrentPageReference } from 'lightning/navigation';

export default class OrderProducts extends LightningElement {
    @api recordId;
    @api title = component.title;
    @api icon = component.icon;
    @api noDataMessage = component.noDataMessage;

    @track loading = true;

    @track controlsConfig = controlConfig;

    @track tableConfig = {
        ...tableConfig,
        onSort: this.onProductsSort.bind(this)
    };

    get orderProductsTemplate() {
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
            this.orderProductsTemplate.notify(error.body.message, 'error');
            this.loading = false;
        } else {
            console.log('data1: ' + JSON.stringify(data, null, '  '));
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

    sort(data, field, direction) {
        const isAscending = direction === 'asc' ? 1 : -1;

        return [...data].sort((x, y) => {
            x = x[field] ? x[field] : '';
            y = y[field] ? y[field] : '';
            return isAscending * ((x > y) - (y > x));
        });
    }
}
