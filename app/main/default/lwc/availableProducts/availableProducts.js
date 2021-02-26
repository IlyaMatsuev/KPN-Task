/**
 * Created by Ilya Matsuev on 2/25/2021.
 */

import { LightningElement, track, api, wire } from "lwc";
import getAvailableProducts from "@salesforce/apex/AvailableProductComponentController.getAvailableProducts";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { columns, sorting } from "./config";

export default class AvailableProducts extends LightningElement {
  @api recordId;
  @track data;
  @track columns = columns;
  @track sortBy = sorting.sortBy;
  @track sortDirection = sorting.sortDirection;
  @track sortByPrioritized = sorting.sortByPrioritized;
  @track searchTerm = "";

  @wire(getAvailableProducts, {
    orderId: "$recordId",
    productNameSearchTerm: "$searchTerm"
  })
  fetchProducts({ data = [], error }) {
    if (error) {
      this.notify(error.body?.message, "error");
    }
    this.data = this.sort(
      data,
      this.sortBy,
      this.sortByPrioritized,
      this.sortDirection
    );
    console.log("data: " + JSON.stringify(this.data, null, "  "));
  }

  onProductsSort({ detail }) {
    this.sortBy = detail.fieldName;
    this.sortDirection = detail.sortDirection;

    this.data = this.sort(
      this.data,
      this.sortBy,
      this.sortByPrioritized,
      this.sortDirection
    );
  }

  onProductSearch({ target }) {
    this.searchTerm = target.value;
  }

  sort(data, field, priorityField, direction) {
    const prioritizedData = data.filter((d) => d[priorityField]);
    const otherData = data.filter((d) => !d[priorityField]);

    const isAscending = direction === "asc" ? 1 : -1;

    const sortingCallback = (x, y) => {
      x = x[field] ? x[field] : "";
      y = y[field] ? y[field] : "";
      return isAscending * ((x > y) - (y > x));
    };

    prioritizedData.sort(sortingCallback);
    otherData.sort(sortingCallback);

    return prioritizedData.concat(otherData);
  }

  notify(message, variant = "success") {
    console.log(message);
    this.dispatchEvent(
      new ShowToastEvent({
        title: variant === "success" ? "Success!" : "Error!",
        message,
        variant,
        mode: "pester"
      })
    );
  }
}
