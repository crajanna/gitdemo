import {
    LightningElement,
    api,
    track,
    wire
} from 'lwc';
import {
    getObjectInfo
} from 'lightning/uiObjectInfoApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';


export default class GetWireObjectInfo extends LightningElement {
    @api objectApiName;
    @track objectInfo;

    @wire(getObjectInfo, {
        objectApiName: ACCOUNT_OBJECT
    })
    objectInfo;
    get objectInfoStr() {
        return this.objectInfo ?
            JSON.stringify(this.objectInfo.data, null, 2) :
            '';
    }
}