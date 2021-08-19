import { LightningElement, wire } from 'lwc';
import getSPChoosePrograms from '@salesforce/apex/ScholarshipController.getSPChoosePrograms';
import { NavigationMixin } from 'lightning/navigation';
//import 'c/cssLibraryFpp';
import 'c/spCssLibraryNew';


export default class SpApplyForScholarship extends NavigationMixin(LightningElement) {
    scholarshipPrograms;
    programs;
    @wire(getSPChoosePrograms) scholarshipPrograms;
    applyBy = 'Apply By ';
    //console.log('apply by '+this.applyBy);


    // connectedCallback() {
    //     getSPChoosePrograms({})
    //         .then(result => {
    //             console.log('* Result * : '+JSON.stringify(result));
    //             this.scholarshipPrograms = result;
    //         })
    //         .catch(error => {
    //             console.log('* ERROR * :'+JSON.stringify(error));
    //         });

    // }



    gotoScholarshipPage(event) {
        let selectProgramId = event.target.dataset.targetId;
        console.log('selectProgramId => ' + selectProgramId);

        let selectProgramName = event.target.dataset.targetName;
        console.log('selectProgramName => ' + selectProgramName);

        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'studentschoralshipwizard'
            },
            state: {
                selectProgramId: selectProgramId
            }
        });
    }


    gotoLearnMorePage(event) {

        let learnMore = event.target.dataset.targetId;
        console.log('learnMore => ' + learnMore);

        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: learnMore
            }
        });
    }

}