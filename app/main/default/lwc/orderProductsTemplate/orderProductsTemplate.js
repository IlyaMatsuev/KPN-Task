/**
 * Created by Ilya Matsuev on 2/28/2021.
 */

import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class OrderProductsTemplate extends LightningElement {
    @api recordId;
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

    @api
    get table() {
        return this.template.querySelector('.products-table');
    }

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
