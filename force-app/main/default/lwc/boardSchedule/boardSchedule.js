import { LightningElement, wire, track } from 'lwc';
import getBoardSchedules from '@salesforce/apex/BoardScheduleController.getBoardSchedules';

export default class BoardSchedule extends LightningElement {

    scheduleDataEvents;
    @track mapOfValues = [];
    @track firstQuarter = [];
    secondQuarter = [];
    thirdQuarter = [];
    fourthQuarter = [];
   
    connectedCallback(){
        getBoardSchedules()
        .then(result => {
            this.scheduleDataEvents = result;
             console.log(result);
             console.log('==>'+JSON.stringify(this.scheduleDataEvents));
        })
        .catch(error => {
            console.log(JSON.stringify(error));
        });
    }
    
    
   
    // @wire(getBoardSchedules) boardScheduleMap({ error, data }) {
    //     if (error) {
    //         console.log(JSON.stringify(error));
    //     } else if (data) {
    //         this.scheduleDataEvents = data;
    //          console.log(data);
    //          console.log('==>'+JSON.stringify(this.scheduleDataEvents));
    //     }
    // }
    
}