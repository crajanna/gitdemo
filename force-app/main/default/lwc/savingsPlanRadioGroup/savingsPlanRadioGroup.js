import { LightningElement, track } from 'lwc';

export default class SavingsPlanRadioGroup extends LightningElement {
    @track selectedValue;

    get spOtions() {
        return [
            { label: 'Simplified', label1: 'NO CUSTOM', value: 'SIMPLIFIED' ,  },
            { label: 'Intermediate', label1: 'SOME CUSTOM', value: 'INTERMEDIATE' },     
            { label: 'Expert', label1: 'FULL CUSTOM', value:'EXPERT' },           
        ];
    }

    // handle the selected value
    handleSelected(event) {
       this.selectedValue = event.target.value;
       var selectedEvent = new CustomEvent('planselection', { detail:  this.selectedValue});
       this.dispatchEvent(selectedEvent);
    }

}