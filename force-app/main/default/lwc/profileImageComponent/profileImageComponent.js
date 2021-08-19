import { LightningElement, track, wire, api } from 'lwc';
import findResourceByRecord from '@salesforce/apex/ResourceController.findResourceByRecord';
import { NavigationMixin } from 'lightning/navigation';
import 'c/cssLibraryFpp';
export default class ProfileImageComponent extends NavigationMixin(LightningElement) {
  
   // @api recordId ='001P000001pOrycIAC';

    @api recordId;
    randomNumber;
    profileImage = [];
    profileFileName;
    profileSrcData;
    @wire(findResourceByRecord, { recordId: '$recordId', description: 'Profile_Logo' })
    findResourceByRecord({ error, data }) {
        if (error) {
          console.log('image-'+error);
        } else if (data) {
          console.log('image-'+data);
           this.profileSrcData = data;
        }
    }


      async handleFileChange(event) {
        if (event.target.files.length !=1) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error updating record',
                    message: "test",
                    variant: 'error'
                })
            );
        } else{
            this.profileImage = await Promise.all(
                [...event.target.files].map(file => this.readFile(file))
              );
              window.console.log( 'this.profileImage[0].base64'+this.profileImage[0].base64);   
              window.console.log( 'fileName'+this.profileImage[0].fileName );   
              this.profileFileName = this.profileImage[0].fileName;
              this.profileSrcData = 'data:image/jpg;base64,'+this.profileImage[0].base64;
              this.sendResidencyDocumentData();
              // Here, you can now upload the files to the server //
        } 
     }

     readFile(fileSource) {
        return new Promise((resolve, reject) => {
          const fileReader = new FileReader();
          const fileName = fileSource.name;
          fileReader.onerror = () => reject(fileReader.error);
          fileReader.onload = () => resolve({ fileName, base64: fileReader.result.split(',')[1]});
          fileReader.readAsDataURL(fileSource);
        });
      }


      sendResidencyDocumentData(){
        const passEvent = new CustomEvent('handleprofileimage', {
          detail:{
              profileImageData:encodeURIComponent(this.profileImage[0].base64),
              profileFileName:this.profileFileName
          } 
      });
       this.dispatchEvent(passEvent);
    }
    connectedCallback(){
      this.randomNumber = Math.random();
    }

    @api
    fetchProfileInfo(selectedId) {
      findResourceByRecord({recordId: selectedId, description: 'Profile_Logo', randomNumber: this.randomNumber})
                .then(data => {
                    if (data) {
                      this.profileSrcData = data;                              
                    }
                })
                .catch(error => {
            });   
    }

    @api
    clearData() {
      this.profileSrcData = null;
    }

}