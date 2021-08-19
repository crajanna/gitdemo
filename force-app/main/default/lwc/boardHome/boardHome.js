import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class BoardHome extends NavigationMixin(LightningElement) {


    handleFloridaPrepaidMaterials(event) {
       this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'materials-prepaid'
            }
        });
    }

    handleFloridaPrepaidBoardMaterials(event) {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'materials-foundation'
            }
        });
    }

    handleAbleUnitedMaterials(event) {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'materials-able'
            }
        });
    }

    handleFloridaPrepaidBoardMember(event) {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'board-members'
            }
        });
    }

    handleFloridaPrepaidBoardBoardMember(event) {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'board-members'
            }
        });
    }

    handleAbleUnitedBoardMember(event) {
        this[NavigationMixin.Navigate]({
            type: 'comm__namedPage',
            attributes: {
                pageName: 'board-members'
            }
        });
    }
}