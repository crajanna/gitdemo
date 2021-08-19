import { LightningElement } from 'lwc';
import getCountyNames from '@salesforce/apex/FPPedgeController.getCountyNames';
import getCountyZipCode from '@salesforce/apex/FPPedgeController.getCountyZipCode';
import getZipCode from '@salesforce/apex/FPPedgeController.getZipCode';

import ProgramFPO from '@salesforce/resourceUrl/testProgramFPO';
import FoundationImages from '@salesforce/resourceUrl/FoundationImages';

export default class TestFPPledgeMakeAPledge extends LightningElement {

    contributionType;
    isCounty = false;
    enableZipCodes = false;
    enableCounty = false;
    countyNames;
    zipCodes;
    howMuch = '';
    state;

    logoURL2 = FoundationImages + '/img/spledge1.jpeg';
    logoURL1 = FoundationImages + '/img/icon-fpo.png';

    heartLogoURL = ProgramFPO + '/icon-heart.svg';
    programLogoURL = ProgramFPO + '/program-fpo.jpeg';

    get heartLogo() {
        return this.logoURL1;
    }

    get programLogo() {
        return this.logoURL2;
    }

    handleChange(event) {

        if (event.target.name == 'contribution') {
            this.contributionType = event.target.value;
            console.log('selected contribution type: ' + this.contributionType);
            if (this.contributionType == 'County') {
                this.template.querySelector('input[name="howMuch"]').value = null;
                this.isCounty = true;
                this.enableCounty = true;
                this.enableZipCodes = false;
                getCountyNames()
                    .then(result => {
                        this.template.querySelector('input[name="howMuch"]').value = null;
                        console.log('countyNames : ' + result);
                        this.countyNames = result;
                    })
                    .catch(error => {
                        this.error = error;
                        console.log('Error while fetching Contact info:' + this.error);
                    });
            } else if (this.contributionType == 'Florida') {
                this.template.querySelector('input[name="howMuch"]').value = null;
                this.isCounty = false;
                this.enableCounty = false;
                this.enableZipCodes = false;
            } else {
                this.template.querySelector('input[name="howMuch"]').value = null;
                this.isCounty = false;

                getZipCode()
                    .then(result => {
                        console.log(this.state + ' country zip Codes : ' + result);
                        this.template.querySelector('input[name="howMuch"]').value = null;
                        this.enableCounty = false;
                        this.enableZipCodes = true;
                        this.zipCodes = result;
                    })
                    .catch(error => {
                        this.error = error;
                        console.log('Error while fetching Contact info:' + this.error);
                    });
            }
        }

        if (event.target.name == 'county') {

            this.template.querySelector('input[name="howMuch"]').value = null;
            this.state = event.target.value;

            if (this.state == 'All') {
                this.enableZipCodes = false;
            } else {
                console.log('state =>' + this.state);
                getCountyZipCode({ countyName: this.state })
                    .then(result => {
                        console.log('cccc ' + this.state + ' country zip Codes : ' + result);
                        this.template.querySelector('input[name="howMuch"]').value = null;
                        this.enableZipCodes = true;
                        this.zipCodes = result;
                    })
                    .catch(error => {
                        this.error = error;
                        console.log('Error while fetching Contact info:' + this.error);
                    });
            }

        }

    if(event.target.name == 'zip') {
    this.template.querySelector('input[name="howMuch"]').value = null;
    this.zip = event.target.value;
}

if (event.target.name == 'howMuch') {
    this.howMuch = event.target.value;
    console.log('Selected Contribute Type:: ' + this.contributionType);
    console.log('Selected State: ' + this.state);
    console.log('Selected Zip Code: ' + this.zip);
    console.log('howMuch :' + this.howMuch);
}


    }

}