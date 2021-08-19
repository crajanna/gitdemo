import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import 'c/cssLibraryFpp';
import My_Resource from '@salesforce/resourceUrl/ECImages'
import getSecuritiesAlllocation from "@salesforce/apex/FundAllocationController.getSecurityAlllocationById";
import getSecuritiesAlllocationAll from "@salesforce/apex/FundAllocationControllerPortal.getSecurityAlllocations";
import saveAllocations from "@salesforce/apex/FundAllocationController.saveAllocations";

export default class FundAllocationsFpp extends LightningElement {

    imagePathIconHelp = My_Resource + '/img/icon-help-circle.png'; 
    @api recordId ;
    @api showAgeBased;
    @api showStaticPortfolios;
    @api showIndFundOptions;
    showTotalAllocaitons;
    activeTab = 'FA';
    @track isLoading = false;
    @api ageFundAbbr;

    @track totalFAPercentage = 0;

    @track fundAllocList = [];
    @track fundAllocListByGroup = [];

    @track fundAllocListStatic = [];
    @track fundAllocListIndividual = [];
    @track fundAllocAgeBased = [];
    
    fundAllocListUpdated = [];
    
    changeHandler(event){
        const field = event.target.name;
        window.console.log("accessKey--" + event.target.accessKey);
            this.fundAllocListUpdated[event.target.accessKey].allocationPercentage = parseFloat( (event.target.value) ? event.target.value : 0);
            this.resetFATotal();           
     }


    resetFATotal (){
        this.totalFAPercentage = 0;
        let tempTotal = 0 
        this.fundAllocListUpdated.forEach(function(item){                   
            if(item.allocationPercentage>0) 
            tempTotal +=  parseFloat(item.allocationPercentage);              
        });
        this.totalFAPercentage = tempTotal;
                      //custom event
       const passEvent = new CustomEvent('allocationselection', {
                        detail:{
                            fundAllocListUpdated:this.fundAllocListUpdated,
                            totalFAPercentage:this.totalFAPercentage
                        } 
                    });
       this.dispatchEvent(passEvent);
    }

    connectedCallback() {
        this.fetchSecuritiesAlllocation();
        this.resetFATotal ();
    }


    ageBasedChangeHandler(event){
        
        /*window.console.log( this.ageFundAbbr);
        window.console.log( event.target.value);
        window.console.log( JSON.stringify(this.fundAllocListUpdated.find(obj => obj.fundAbbr == this.ageFundAbbr)));

        this.fundAllocListUpdated.find(obj => obj.fundAbbr == this.ageFundAbbr).allocationPercentage = parseFloat( (event.target.value) ? event.target.value : 0);
        this.resetFATotal();*/
    }

    fetchSecuritiesAlllocation() {
        this.isLoading = true;
        getSecuritiesAlllocationAll()
            .then(result => {
                if (result) {
                    console.log(result);                    
                       this.fundAllocList = result;
                       this.fundAllocListByGroup = result.reduce((r, a) => {
                            r[a.fundCategory] = [...r[a.fundCategory] || [], a];
                            return r;
                           }, {});
                           this.fundAllocListStatic = this.fundAllocListByGroup['Static'];
                           this.fundAllocListIndividual = this.fundAllocListByGroup['Individual'];
                           this.fundAllocAgeBased  = this.fundAllocListByGroup['Age Based'];
                        this.fundAllocListUpdated = JSON.parse(JSON.stringify(result));
                  
                }
                this.isLoading = false;
            })
            .catch(error => {
                console.error("Error in fetching fund allocations" , error);
                this.isLoading = false;
            });       
    }


    handleSubmit(event) {
        if( (this.activeTab == 'FA' && this.totalFAPercentage != 100) ){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error creating record',
                    message: 'Allocation total percentage must be equal to 100%.',
                    variant: 'error'
                })
            );
        }else{
           saveAllocations({'allocations': JSON.stringify(this.fundAllocListUpdated), 'accountId': this.recordId})
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

}