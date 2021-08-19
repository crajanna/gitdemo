import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import 'c/cssLibraryFpp';
import My_Resource from '@salesforce/resourceUrl/ECImages'
import getSecuritiesAlllocation from "@salesforce/apex/FundAllocationController.getSecurityAlllocationById";
import saveAllocations from "@salesforce/apex/FundAllocationController.saveAllocations";
import rebalanceAllocations from "@salesforce/apex/RebalanceAllocations.rebalanceAllocations";
import getRebalanceCount from "@salesforce/apex/RebalanceAllocations.getRebalanceCount";

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class FundAllocations extends LightningElement {
    @api recordId = 'a0FP0000007mwVpMAI';
    activeTab = 'FA';
    @track isLoading = false;
    imagePathIconHelp = My_Resource + '/img/icon-help-circle.png'; 

    @track totalFAPercentage = 100;
    @track totalRAPercentage = 100;
    @track rebalanceCount = 0;

    @track fundAllocList = [];
    fundAllocListUpdated = [];

    @track reBalAllocList = [];
    reBalAllocListUpdated = [];
    showAgeBased =true;
    showStaticPortfolios =true;
    showIndFundOptions =true;
    birthdate = null;

    changeHandler(event){
        const field = event.target.name;
        if(this.activeTab == 'FA') {
            this.fundAllocListUpdated[event.target.accessKey].allocationPercentage = parseFloat( (event.target.value) ? event.target.value : 0);
            this.resetFATotal();
        }else {
            this.reBalAllocListUpdated[event.target.accessKey].allocationPercentage = parseFloat( (event.target.value) ? event.target.value : 0);
            this.resetRATotal();
        }
     }

     ageBasedChangeHandler(event){
        
        /*window.console.log( this.ageFundAbbr);
        window.console.log( event.target.value);
        window.console.log( JSON.stringify(this.fundAllocListUpdated.find(obj => obj.fundAbbr == this.ageFundAbbr)));

        this.fundAllocListUpdated.find(obj => obj.fundAbbr == this.ageFundAbbr).allocationPercentage = parseFloat( (event.target.value) ? event.target.value : 0);
        this.resetFATotal();*/
    }

     handleTab(event){
        this.activeTab = event.target.value;
        this.fetchSecuritiesAlllocation();
     }

    resetFATotal (){
        this.totalFAPercentage = 0;
        let tempTotal = 0 
        this.fundAllocListUpdated.forEach(function(item){                   
            if(item.allocationPercentage>0) 
            tempTotal +=  parseFloat(item.allocationPercentage);              
        });
        this.totalFAPercentage = tempTotal;
    }

    resetRATotal (){
        this.totalRAPercentage = 0;
        let tempTotal = 0 
        this.reBalAllocListUpdated.forEach(function(item){                   
            if(item.allocationPercentage>0) 
                 tempTotal +=  parseFloat(item.allocationPercentage);              
        });
        this.totalRAPercentage = tempTotal;
    }

    connectedCallback() {
        this.fetchSecuritiesAlllocation();
    }

    fetchSecuritiesAlllocation() {
        console.log(this.activeTab);
        this.isLoading = true;
        getSecuritiesAlllocation({'accountId': this.recordId, 'allocationType': this.activeTab})
            .then(result => {
                if (result) {
                    console.log(result);
                    if(this.activeTab == 'FA') {
                        this.fundAllocList = result;
                        this.fundAllocListUpdated = JSON.parse(JSON.stringify(result));
                    }else {
                        this.reBalAllocList = result;
                        this.reBalAllocListUpdated = JSON.parse(JSON.stringify(result));
                    }
                }
                this.isLoading = false;
            })
            .catch(error => {
                console.error("Error in fetching fund allocations" , error);
                this.isLoading = false;
            });

            getRebalanceCount({'accountId': this.recordId})
                .then(result => {
                    if (result) {
                        console.log(result);
                        this.rebalanceCount = result;
                    }
                })
                .catch(error => {
                    console.error("Error in getRebalanceCount" , error);
                });    
       
    }

    handleSubmit(event) {
        console.log('in allocations submit' + this.activeTab  );
        if( (this.activeTab == 'FA' && this.totalFAPercentage != 100)  || (this.activeTab == 'RA' && this.totalRAPercentage!=100)){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating record',
                    message: 'Allocation total percentage must be equal to 100%.',
                    variant: 'error'
                })
            );
        }else{
           saveAllocations({'allocations': JSON.stringify(this.activeTab == 'FA' ? this.fundAllocListUpdated : this.reBalAllocListUpdated), 'accountId': this.recordId})
            .then(result => {
                if(result){
                    this.fetchSecuritiesAlllocation();
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: 'Allocation save sucessfully.',
                            variant: 'success'
                        })
                    );
                } else
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: 'Error saving allocations, please contact administrator.',
                            variant: 'error'
                        })
                    );

            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: reduceErrors(error).join(', '),
                        variant: 'error'
                    })
                );
            });

            //console.log(this.fundAllocListUpdated);
           // console.log(this.reBalAllocListUpdated);
        }
    }

    onAllocationSelection(event){
        this.fundAllocListUpdated = event.detail.fundAllocListUpdated;
        this.totalFAPercentage =event.detail.totalFAPercentage;
        window.console.log("plan selection this.fundAllocListUpdated......"+JSON.stringify(this.fundAllocListUpdated));
    }

    handleRebalance(event) {
        rebalanceAllocations({'accountId': this.recordId})
        .then(result => {
            if(result){
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Rebalancing transactions recorded sucessfully.',
                        variant: 'success'
                    })
                );
                this.fetchSecuritiesAlllocation() ;
            } else
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Error saving allocations, please contact administrator.',
                        variant: 'error'
                    })
                );

        })
        .catch((error) => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Error saving allocations, please contact administrator.',
                    variant: 'error'
                })
            );
        });
    }

}