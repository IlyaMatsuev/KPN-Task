/**
 * Created by Ilya Matsuev on 2/28/2021.
 */

import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import STATUS_FIELD from '@salesforce/schema/Order.Status';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class OrderProductsTemplate extends LightningElement {
    @api orderId;
    @api title;
    @api icon;
    @api noDataMessage;
    @api loading;
    @api tableConfig;
    @api controlsConfig;

    get haveData() {
        return (
            this.tableConfig &&
            this.tableConfig.data &&
            this.tableConfig.data.length > 0
        );
    }

    get buttonDisabled() {
        return this.loading || this.orderStatus === 'Activated';
    }

    get checkboxesHidden() {
        return (
            this.tableConfig.hideCheckboxes || this.orderStatus === 'Activated'
        );
    }

    get orderStatus() {
        if (this.order && this.order.data) {
            return this.order.data.fields[STATUS_FIELD.fieldApiName].value;
        }
        return '';
    }

    @api
    get table() {
        return this.template.querySelector('.products-table');
    }

    @wire(getRecord, {
        recordId: '$orderId',
        fields: [STATUS_FIELD]
    })
    order;

    @api
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
}
