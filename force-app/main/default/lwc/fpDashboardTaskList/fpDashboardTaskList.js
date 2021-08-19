import { LightningElement, api } from 'lwc';
import FoundationImages from '@salesforce/resourceUrl/FoundationImages';
import { NavigationMixin } from 'lightning/navigation';
import 'c/spCssLibraryNew';
export default class FpDashboardTaskList extends NavigationMixin(LightningElement) {
    @api taskData;
    taskIcon = FoundationImages + "/img/icon-tasks.svg";

    handleNavigte(event){
        const result = this.taskData.filter(task => task.Id === event.target.name);
        if(result[0].description.split(':')[0] === 'event'){
            this.dispatchEvent(new CustomEvent(result[0].description.split(':')[1]));
        }else {
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    pageName: result[0].description
                }
            });
        }
    }
    handleAllTask(event) {
        event.preventDefault();
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'my-tasks'
            }, state: {
                accountId: this.accountIduser
            }
        });
    }
}