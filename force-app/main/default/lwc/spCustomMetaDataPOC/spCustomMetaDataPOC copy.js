import { LightningElement, api, wire } from 'lwc';
import getScholarshipApplicationDetails from '@salesforce/apex/ScholarshipController.getScholarshipApplicationDetails';
import saveTheChunkFile from '@salesforce/apex/FileUploadService.saveTheChunkFile';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import 'c/spCssLibraryNew';

const MAX_FILE_SIZE = 45000000;
const CHUNK_SIZE = 750000;
export default class SpCustomMetaDataPOC extends LightningElement {

    
    id;
    label;
    academicInterests;
    communityChampions;
    essayContest;
    organizationsList;
    studentStatement;
    tabName;
    videoStatement;
    scholarshipApplication;
    myVal;
    validity = true;
    errorMessage;
    displayNext = true;
    displayBlackHistoryMonth = false;
    displayBoysAndGirls = false;
    

    //Black History Month - 01tP0000007N1BiIAK
    //Boys and Girls - 01tP0000007N1BnIAK

    @wire(getScholarshipApplicationDetails, {prodictId: '01tP0000007N1BnIAK'})
    scholarApplication ({error, data}) {
        if (error) {
            console.log('ERROR : '+error);
        } else if (data) {
            this.scholarshipApplication = data;
            console.log('scholarshipApplication ==> '+JSON.stringify(this.scholarshipApplication));

            this.id = this.scholarshipApplication.Id;
            this.label = this.scholarshipApplication.Label;
            this.academicInterests = this.scholarshipApplication.Academic_Interests__c;
            this.communityChampions = this.scholarshipApplication.Community_Champions__c;
            this.essayContest = this.scholarshipApplication.Essay_Contest__c;
            this.organizationsList = this.scholarshipApplication.Organizations_List__c;
            this.studentStatement = this.scholarshipApplication.Student_Statement__c;
            this.tabName = this.scholarshipApplication.Tab_Name__c;
            this.videoStatement = this.scholarshipApplication.Video_Statement__c;

            console.log('id : '+this.id+' --- label: '+this.label+' --- academicInterests: '+this.academicInterests+' --- communityChampions: '+this.communityChampions
            +' --- essayContest: '+this.essayContest+' --- organizationsList: '+this.organizationsList+' --- studentStatement: '+this.studentStatement+' --- tabName: '+this.tabName+' --- videoStatement: '+this.videoStatement);

        }
    }

    handleClick( event ) {
        this.myVal = event.target.value;
        let arr = this.myVal.split(' ');
        if(arr.length > 500){
            this.validity = false;
            this.displayNext = false;
            this.errorMessage = "The length of the description has exceeded the maximum limit.";
        } else{
            this.errorMessage = "";
            this.validity = true;
            this.displayNext = true;
        }
    }



    @api recordId;

    fileName = '';
    filesUploaded = [];
    isLoading = false;
    fileSize;

    handleFilesChange(event) {
        if(event.target.files.length > 0) {
            this.filesUploaded = event.target.files;
            this.fileName = event.target.files[0].name;
        }
    }

    saveFile(){
        var fileCon = this.filesUploaded[0];
        this.fileSize = this.formatBytes(fileCon.size, 2);
        if (fileCon.size > MAX_FILE_SIZE) {
            let message = 'File size cannot exceed ' + MAX_FILE_SIZE + ' bytes.\n' + 'Selected file size: ' + fileCon.size;
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: message,
                variant: 'error'
            }));
            return;
        }
        var reader = new FileReader();
        var self = this;
        reader.onload = function() {
            var fileContents = reader.result;
            var base64Mark = 'base64,';
            var dataStart = fileContents.indexOf(base64Mark) + base64Mark.length;
            fileContents = fileContents.substring(dataStart);
            self.upload(fileCon, fileContents);
        };
        reader.readAsDataURL(fileCon);
    }

    upload(file, fileContents){
        var fromPos = 0;
        var toPos = Math.min(fileContents.length, fromPos + CHUNK_SIZE);
        
        this.uploadChunk(file, fileContents, fromPos, toPos, ''); 
    }

    uploadChunk(file, fileContents, fromPos, toPos, attachId){
        this.isLoading = true;
        var chunk = fileContents.substring(fromPos, toPos);
        
        saveTheChunkFile({ 
            parentId: this.recordId,
            fileName: file.name,
            base64Data: encodeURIComponent(chunk), 
            contentType: file.type,
            fileId: attachId
        })
        .then(result => {
            
            attachId = result;
            fromPos = toPos;
            toPos = Math.min(fileContents.length, fromPos + CHUNK_SIZE);    
            if (fromPos < toPos) {
                this.uploadChunk(file, fileContents, fromPos, toPos, attachId);  
            }else{
                this.dispatchEvent(new ShowToastEvent({
                    title: 'Success!',
                    message: 'File Upload Success',
                    variant: 'success'
                }));
                this.isLoading = false;
            }
        })
        .catch(error => {
            console.error('Error: ', error);
        })
        .finally(()=>{
            
        })
    }

    formatBytes(bytes,decimals) {
        if(bytes == 0) return '0 Bytes';
        var k = 1024,
            dm = decimals || 2,
            sizes = ['Bytes', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB'],
            i = Math.floor(Math.log(bytes) / Math.log(k));
        return parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i];
    }



  
    get acceptedFormats() {
        return ['.vi', '.mov', '.mpeg', '.mpg', '.swf', '.mp4', '.png','.jpg','.jpeg'];
    }
    handleUploadFinished(event) {
        // Get the list of uploaded files
        const uploadedFiles = event.detail.files;
        let uploadedFileNames = '';
        for(let i = 0; i < uploadedFiles.length; i++) {
            uploadedFileNames += uploadedFiles[i].name + ', ';
        }
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: uploadedFiles.length + ' Files uploaded Successfully: ' + uploadedFileNames,
                variant: 'success',
            }),
        );
    }


  
    // get acceptedFormats() {
    //     return ['.pdf', '.png','.jpg','.jpeg'];
    // }
    // handleUploadFinished(event) {
    //     // Get the list of uploaded files
    //     const uploadedFiles = event.detail.files;
    //     let uploadedFileNames = '';
    //     for(let i = 0; i < uploadedFiles.length; i++) {
    //         uploadedFileNames += uploadedFiles[i].name + ', ';
    //     }
    //     this.dispatchEvent(
    //         new ShowToastEvent({
    //             title: 'Success',
    //             message: uploadedFiles.length + ' Files uploaded Successfully: ' + uploadedFileNames,
    //             variant: 'success',
    //         }),
    //     );
    // }

    
}