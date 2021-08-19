import { LightningElement, wire } from 'lwc';
import getScholarshipApplicationReview from '@salesforce/apex/ScholarshipController.getScholarshipApplicationReview';
import userId from '@salesforce/user/Id';
import 'c/spCssLibraryNew';

export default class SpDashboardApplicationReview extends LightningElement {

    ownerId = userId;
    products;
    connectedCallback() {
        console.log('loggedInUserId ==>' + this.loggedInUserId);
    }
    @wire(getScholarshipApplicationReview, { userId: '$ownerId' }) reviews;

}