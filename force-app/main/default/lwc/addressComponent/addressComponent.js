import { LightningElement, track, wire, api } from 'lwc';
import getAccountAddress from '@salesforce/apex/CreatePersonAccount.getAccountAddress';
import getStateOptions from '@salesforce/apex/CreatePersonAccount.getStateOptionsList';
import getCountryOptions from '@salesforce/apex/CreatePersonAccount.getCountryOptionsList';

export default class AddressComponent extends LightningElement {

    street;
    city;
    countryCode;
    stateCode;
    postalCode;
    country;
    state;
    randomNumber;

    address = {
        street: '',
        city: '',
        province: '',
        postalCode: '',
        country: '',
    };
    
    addressList = [
        {label: "Add New Address", value: "NEW", address:''}
    ];

    @track countryValues = []; 
    @track stateValues = [];

    @wire(getStateOptions)
    mapOfStateData({data, error}) {
         if(data) {           
             for(let key in data) {                
                 // Preventing unexcepted data
                  if (data.hasOwnProperty(key)) { 
                      this.stateValues.push({"label":key, "value":data[key]});
                  }
             }
         }
         else if(error) {
             window.console.log(error);
         }
     }

     @wire(getCountryOptions)
     mapOfCountryData({data, error}) {
          if(data) {                
              for(let key in data) {
                  // Preventing unexcepted data
                  if (data.hasOwnProperty(key)) { 
                      this.countryValues.push({"label":key, "value":data[key]});
                  }
              }
              this.address.country = this.countryValues[0].value;
          }
          else if(error) {
              window.console.log(error);
          }
      }

      get getProvinceOptions() {
        return this.stateValues = [...this.stateValues];
    }
    get getCountryOptions() {
        return this.countryValues = [...this.countryValues];
    }

    handleAddressChange(event){
      
        if(event.target.value != undefined){
            this.address.street = '';
            this.address.city  = '';
            this.address.province = '';
            this.address.postalCode  = '';
            this.address.country  = '';
            console.log('adddd'+JSON.stringify(this.addressList.find(opt => opt.value === event.target.value).address));
            var address = this.addressList.find(opt => opt.value === event.target.value).address;
            this.street = address.street;
            tdhis.city = address.city;
            this.countryCode= address.countryCode;
            this.stateCode = address.stateCode;
            this.postalCode= address.postalCode;
            this.sendAddressData();
        }else{

            this.address.street = event.detail.street;
            this.address.city  = event.detail.city;
            this.address.province = event.detail.province;
            this.address.postalCode  = event.detail.postalCode;
            this.address.country  = event.detail.country; 
           
            this.sendAddressData();
        }
    }


    sendAddressData(){
        const passEvent = new CustomEvent('handleaddressinfo', {
            detail:{
                street:  this.address.street,
                city: this.address.city, 
                province: this.getProvinceOptions.find(opt => opt.value === this.address.province).label,
                postalCode: this.address.postalCode,
                country: this.getCountryOptions.find(opt => opt.value === this.address.country).label, 
                countryCode:this.address.country,
                stateCode:this.address.province

            } 
        });
         this.dispatchEvent(passEvent);
    }

    connectedCallback(){
        this.randomNumber = Math.random();
    }
    @api
    fetchAddressInfo(selectedId) {
        this.addressList = [];

        getAccountAddress({'accountId': selectedId, randomNumber: this.randomNumber})
        .then(data => {
            if (data) {
                console.log('address..'+JSON.stringify(data));
                if(data.BillingAddress){
                    if(data.BillingAddress.street){
                        var addressVar = {
                            street : data.BillingAddress.street,
                            city: data.BillingAddress.city,
                            stateCode: data.BillingAddress.stateCode,
                            postalCode:data.BillingAddress.postalCode,
                            state:data.BillingAddress.state,
                            country:data.BillingAddress.country,
                            countryCode:data.BillingAddress.countryCode
                         }
                        const option = {
                            label: data.BillingAddress.street +', ' + data.BillingAddress.city +', ' + data.BillingAddress.stateCode +' ' + data.BillingAddress.postalCode,
                            value: 'BillingAddress',
                            address: addressVar
                        };
                        this.addressList = [ ...this.addressList, option ];

                        this.address.street = data.BillingAddress.street;
                        this.address.city = data.BillingAddress.city;
                        this.address.province = data.BillingAddress.stateCode;
                        this.address.country = data.BillingAddress.countryCode,
                        this.address.postalCode  =  data.BillingAddress.postalCode;

                    }
                 
                }

                this.addNewAddress();
                   
            }
        })
        .catch(error => {
            console.error("Error in fetching contact information" , error);
        });  
    }

    @api
    clearData() {
        this.addressList = []; 
        this.addNewAddress();
        this.address = {
            street: '',
            city: '',
            province: '',
            postalCode: '',
            country: '',
        };
    }

    addNewAddress(){
        const option = {label: "Add New Address", value: "NEW", address:''};
        this.addressList = [ ...this.addressList, option ];
    }

}