import { LightningElement } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
export default class TestScript extends LightningElement {

    renderedCallback() { // invoke the method when component rendered or loaded
        Promise.all([
            loadScript(this, 'https://www.paypal.com/sdk/js?client-id=sb&currency=USD'),  // leaflet js file
        ])
        .then(() => { 
            this.error = undefined;
            paypal.Buttons({
                createOrder: function(data, actions) {
               return actions.order.create({
                   purchase_units: [
                       {
                           amount: {
                               currency_code: "USD",
                               value: "3.87"
                           }
                       }
                   ]
               });
           },
                       onApprove: function(data, actions) {
               return actions.order.capture().then(function(details) {
                    alert('Congratulations! payment success');
                    console.log(details);
                    console.log(details.id);  // order id
                    console.log(details.status);  // 'COMPLETED'
                                        // send ajax request to update the db
               });
           },
                       onCancel: function (data) {
               alert('Payment cancelled');
             }
           }).render('#payment-buttons');
        })
        .catch(error => {
            this.error = error;
        });
       
    }

}