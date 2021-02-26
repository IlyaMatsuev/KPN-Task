# KPN Practice Task

This repository is a place where all my work on the KPN task will be done.

The README contains information about the requirements for the task and how to deploy the application for a demo.

- [General Requirement](#general-requirement)
- [Detailed Requirements](#detailed-requirements)
- [Extra Requirements](#extra-requirements)
- [Installation](#installation)

## General Requirement

Build 2 LWC components and put them on order record page:

1. "Available Products" - displays available products suitable for Order based on Order’s price book
2. "Order Products" – displays products added to the current order

## Detailed Requirements

- [x] The solution is available as a repository on GitHub/Bitbucket etc

  - [x] Code should be deployable using SFDX
  - [x] Use git readme for feedback and notes
  - [x] Try to commit while developing

- [x] The “Available Products” component displays orderable products in a 2-column list displaying Name and List Price
  - [x] Products that are already added to the order should appear on top
  - [x] Each product can only appear once in the list
  - [x] **(Optional)** Sort by column
  - [x] **(Optional)** Search by product name
- [ ] The “Available Products” component has to provide the ability for the user to add a product from the list to the order
  - [ ] When the same product is not yet added to the order it will be added with a quantity of 1
  - [ ] When the product already exists the quantity of the existing order product should be increased by 1
- [ ] “Order Products” component has to display the order products in a table displaying the Name, Unit Price, Quantity and Total Price
  - [ ] When the user adds a new product or updates an existing product on the order (see point 3) the list is refreshed to display the newly added
  - [ ] **(Optional)** Sort the list by column
- [ ] “Order Products” component has an “Activate” button that sets the status of the order and order items to “Activated”

  - [ ] When activated the end user will not be able to add new order items or confirm the order for a second time

- [ ] A test coverage of at least 80% for both APEX components is required

- [ ] We would like to see LWC, but Aura/Vlocity is ok as well

- [ ] Please use apex for queries, DMLs

- [x] Create a Salesforce Developer login for this assignment and build it as a SFDX project

## Extra Requirements

- [ ] Components should be independent (we should be able to drag and drop them at any place in the layout)

  - [ ] To ensure an optimal user experience the page should not be reloaded and only the changed or new items should be refreshed/added

- [ ] Extend the logic of “Order Products” component’s “Activate” button to do the confirmation of the order in an external system

  - [ ] The request format expected by the external system should follow the following JSON structure:

  ```json
  {
    "accountNumber": "",
    "orderNumber": "",
    "type": "order type",
    "status": "order status",
    "orderProducts": [
      {
        "name": "product name",
        "code": "product code",
        "unitPrice": 10.0,
        "quantity": 1
      }
    ]
  }
  ```

  - [ ] Request is sent as POST
  - [ ] Order of the JSON fields in the above JSON structure is not relevant, but the data type is
  - [ ] Errors and time-outs of the external system need to be handled
    - [ ] All 200 responses are considered OK
    - [ ] Any non-200 response is handled as ERROR
    - [ ] For this use case generate a new endpoint URL at https://requestcatcher.com/
    - [ ] We prefer to see this implemented using apex

- [ ] The number of products can exceed 200; the solution needs to be able to handle this while providing a proper user experience

## Installation

1. Clone the project

```bash
git clone https://github.com/IlyaMatsuev/KPN-Task.git
```

2. Go to the root project directory

```bash
cd ./kpn-task
```

3. Run init script with such parameters as scratch alias, dev hub alias and amount of days the scratch will expire (optional).

```bash
./scripts/bash/init-scratch.sh {SCRATCH_ALIAS} {DEV_HUB_ALIAS} {EXPIRED_IN_DAYS}
```

4. Follow the instructions in script
