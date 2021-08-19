import { LightningElement } from 'lwc';

export default class UtilBeneficiaryType extends LightningElement {
    handleChange(event){
        var elementName = event.target.name;
        var elementValue = event.target.value;

        const userInput = new CustomEvent('headerinput', {detail: {name: elementName, value: elementValue}});
        this.dispatchEvent(userInput);

    }
}