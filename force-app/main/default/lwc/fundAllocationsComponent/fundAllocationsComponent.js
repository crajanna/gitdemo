import { LightningElement, api, track } from 'lwc';
import 'c/cssLibraryFpp';
import My_Resource from '@salesforce/resourceUrl/ECImages'
import getSecuritiesAlllocation from "@salesforce/apex/FundAllocationController.getSecurityAlllocationById";
import hasNoBeneficiary from "@salesforce/apex/FundAllocationController.hasNoBeneficiary";

export default class FundAllocationsComponent extends LightningElement {
    imagePathIconHelp = My_Resource + '/img/icon-help-circle.png'; 
    @api recordId;
    @api showAgeBased;
    @api noBeneficiaryInAccount = false;
    @api showStaticPortfolios;
    @api showIndFundOptions;
    @api dob;
    showTotalAllocaitons;
    activeTab = 'FA';
    @track isLoading = false;
    @api ageFundAbbr;

    @track totalFAPercentage = 0;

    @track fundAllocList = [];
    fundAllocListUpdated = [];
    
    changeHandler(event){
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
        this.resetFATotal();
        if(this.recordId!=null){
            this.totalFAPercentage = 100;
        }
    }

    fetchSecuritiesAlllocation() {

        this.isLoading = true;
        var tmpDob = null;
        if(this.dob != null){
            var month = this.dob.getUTCMonth() + 1; 
            var day = this.dob.getUTCDate();
            var year = this.dob.getUTCFullYear();
    
            tmpDob = year + "-" + month + "-" + day;
        }

        if(this.recordId!=null){
            hasNoBeneficiary({'accountId': this.recordId})
            .then(result => {
                if (result) {
                    this.noBeneficiaryInAccount = result;                   
                }
            })
            .catch(error => {
                console.error("Error in fetching hasNoBeneficiary" , error);
            });  
        }        

        getSecuritiesAlllocation({'accountId': this.recordId, 'allocationType': this.activeTab, 'matriculationDate': tmpDob})
            .then(result => {
                if (result) {
                    this.fundAllocList = result;
                    this.fundAllocListUpdated = JSON.parse(JSON.stringify(result));
                   
                }
                this.isLoading = false;
            })
            .catch(error => {
                console.error("Error in fetching fund allocations" , error);
                this.isLoading = false;
            });      
    }

}