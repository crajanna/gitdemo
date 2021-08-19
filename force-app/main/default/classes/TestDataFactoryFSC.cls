@isTest
public class TestDataFactoryFSC {
    public static void createAgeBasedPortfolioData(){

        
        //1 Person Account
        Id recordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

        Integer year = Datetime.now().Year();
        Date birthDate = Date.newInstance(year-4, Datetime.now().Month(), Datetime.now().Day());
        Account newAccount = createPersonAccount();
        //2 related Contact
        /*Contact newContact = new Contact(FirstName='test',
                                         LastName='test',
                                         Email='test@test.com', 
                                         AccountId = newAccount.Id,
                                         Birthdate = birthDate);
        insert newContact;*/
        System.debug('Contact : '+[Select Id,Birthdate From Contact Where accountId = :newAccount.Id]);
        //3.Finance Account
		//List<FinServ__FinancialAccount__c> lstFinAcc = new List<FinServ__FinancialAccount__c>();        
       	FinServ__FinancialAccount__c cashAccount = createCashAccount(newAccount.Id);
        FinServ__FinancialAccount__c finAccount = create529Account(newAccount.Id);
        /*new FinServ__FinancialAccount__c(FinServ__FinancialAccountType__c='Cash Account',
                                         FinServ__PrimaryOwner__c =newAccount.Id, 
                                         FinServ__FinancialAccountNumber__c = '123456', 
                                         FinServ__Balance__c = 10000,
                                         Name='Cash Account');
    
        lstFinAcc.add(finAccount);
        insert lstFinAcc;*/

        createTransferFundRecord(finAccount.Id,cashAccount.Id);

        //5.Financial Security
        List<FinServ__Securities__c> finSecurityList = new List<FinServ__Securities__c>();
        FinServ__Securities__c finSecurity = new FinServ__Securities__c(
                                                 Name = 'ABM0'+String.valueOf(0),
                                                 FinServ__SecuritiesName__c = 'Age-Based Portfolio-ABM0'+String.valueOf(4),
                                                 Fund_Category__c = 'Age Based',
                                                 Ext_Security_ID__c = String.Valueof(12345 + 0),
                                                 FinServ__Price__c = 1000,
                                                 Fund_Fee__c= 2,
                                                 Admin_Fee__c = 2,
                                                 FinServ__AssetClass__c = 'Multi',
                                                 Inception_Date__c = date.today().addyears(6),
                                                 Inception_Price__c = 3000 );
            finSecurityList.add(finSecurity);

            FinServ__Securities__c finSecurity1 = new FinServ__Securities__c(
                                                 Name = 'ABM0'+String.valueOf(8),
                                                 FinServ__SecuritiesName__c = 'Age-Based Portfolio-ABM0'+String.valueOf(8),
                                                 Fund_Category__c = 'Age Based',
                                                 Ext_Security_ID__c = String.Valueof(12345 + 8),
                                                 FinServ__Price__c = 1000,
                                                 Fund_Fee__c= 2,
                                                 Admin_Fee__c = 2,
                                                 FinServ__AssetClass__c = 'Multi',
                                                 Inception_Date__c = date.today().addyears(6),
                                                 Inception_Price__c = 3000 );
            finSecurityList.add(finSecurity1);
        insert finSecurityList;
        createInvestmentTransaction(finAccount.id,finSecurityList[0].Id);
        createPriceHistoryRecord(finSecurityList[0].Id);
        createPriceHistoryRecord(finSecurityList[1].Id);
        List<Fund_Allocation__c> FundAllocationList = new List<Fund_Allocation__c>();
        for(FinServ__Securities__c finSec : finSecurityList){
            Fund_Allocation__c fAloc = new Fund_Allocation__c();
            fAloc.Securities__c = finSec.Id;
            fAloc.Financial_Account__c = cashAccount.Id;
            fAloc.allocation_percentage__c = 45;
            fAloc.Active_Indicator__c = 'Yes';
            FundAllocationList.add(fAloc);
        }
        insert FundAllocationList;
        
        //create financial holding under investment account
        list<FinServ__FinancialHolding__c> list_holding  = new List<FinServ__FinancialHolding__c>();
        FinServ__FinancialHolding__c tempholding  = new FinServ__FinancialHolding__c();
        tempholding.FinServ__FinancialAccount__c = cashAccount.id;
        tempholding.Name = 'Test Holding';
        tempholding.FinServ__MarketValue__c = 100;
        tempholding.FinServ__Securities__c = finSecurityList[0].Id;
        tempholding.FinServ__Shares__c = 1;
        tempholding.FinServ__Price__c = 100;
        tempholding.Cost_Basis__c = 100;
        list_holding.add(tempholding);
        
        
        /*FinServ__FinancialHolding__c tempholding1  = new FinServ__FinancialHolding__c();
        tempholding1.FinServ__FinancialAccount__c = finAccount.id;
        tempholding1.Name = 'Test Holding1';
        tempholding1.FinServ__MarketValue__c = 1000;
        tempholding1.FinServ__Securities__c = finSecurityList[1].Id;
        list_holding.add(tempholding1);*/
        
        insert list_holding;

        //4.Financial Account role
        FinServ__FinancialAccountRole__c finAccRole = new FinServ__FinancialAccountRole__c(
            FinServ__Active__c = true,
            FinServ__FinancialAccount__c = cashAccount.Id,
            FinServ__Role__c = 'Beneficiary',
            Beneficiary_Relationship__c = 'Son or daughter or a descendant of either',
            FinServ__RelatedAccount__c = newAccount.id
        );
        insert finAccRole;

        System.debug('FAR : '+[SELECT Id,FinServ__FinancialAccount__c,FinServ__FinancialAccount__r.FinServ__Balance__c, FinServ__Active__c,FinServ__Role__c,FinServ__RelatedAccount__r.PersonContact.Birthdate FROM FinServ__FinancialAccountRole__c ]);

    
    }
    
    public static Account createPersonAccount(){
        Id recordTypeId = Account.sObjectType.getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();

        Integer year = Datetime.now().Year();
        Date birthDate = Date.newInstance(year-4, Datetime.now().Month(), Datetime.now().Day());
        Account newAccount = new Account(FirstName='FTestName',
                                         LastName='LName',
                                         Email__c = 'test@test.com', 
                                         Phone = '999999999', 
                                         SSN2__pc = '9999',
                                         PersonBirthdate = birthDate,
                                         RecordTypeId = recordTypeId);
        insert newAccount;
        return  newAccount;
    }

    public static FinServ__FinancialAccount__c createCashAccount(Id id){
        Id recordTypeId = FinServ__FinancialAccount__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('General Account').getRecordTypeId();
        FinServ__FinancialAccount__c cashAccount = 
            new FinServ__FinancialAccount__c(FinServ__FinancialAccountType__c='Cash Account',
            FinServ__PrimaryOwner__c =id, 
            FinServ__FinancialAccountNumber__c = '123456', 
            FinServ__CashBalance__c = 1000,
            Name='Cash Account',
            RecordTypeId = recordTypeId);
            insert cashAccount;
            return  cashAccount;
    }

    public static FinServ__FinancialAccount__c create529Account(Id id){
        Id recordTypeId = FinServ__FinancialAccount__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Investment Account').getRecordTypeId();
        FinServ__FinancialAccount__c faccount = 
            new FinServ__FinancialAccount__c(FinServ__FinancialAccountType__c='Regular',
            FinServ__PrimaryOwner__c =id, 
            FinServ__FinancialAccountNumber__c = '99999', 
            Name='Florida 529 Savings Plan',
            RecordTypeId = recordTypeId);
            insert faccount;
            return  faccount;
    }

    public static List<Investment_Transaction__c> createInvestmentTransaction(Id financeAccountId,Id securityRecordId){
        List<Investment_Transaction__c> InvTransactionList = new List<Investment_Transaction__c>(); 
        Investment_Transaction__c  InvTransactionObj = new Investment_Transaction__c();
        InvTransactionObj.Action_Type__c = 'Buy';
        InvTransactionObj.Financial_Account__c = financeAccountId;
        Decimal cost = 1000; 
        Decimal price = 10;
        InvTransactionObj.Cost_Basis__c = cost;
        InvTransactionObj.Buy_Amount__c = cost;                                                   
        InvTransactionObj.shares_quantity__c = cost/price;
        InvTransactionObj.Purchase_Price__c = price;
        InvTransactionObj.Securities__c = securityRecordId;
        InvTransactionObj.Status__c = 'Processing';
        InvTransactionObj.Initiator_Type__c = 'Beneficiary/Age Update';
        InvTransactionObj.Transaction_Date__c = System.now();
        InvTransactionList.add(InvTransactionObj);  

        Investment_Transaction__c  InvTransactionObj1 = new Investment_Transaction__c();
        InvTransactionObj1.Action_Type__c = 'Sell';
        InvTransactionObj1.Financial_Account__c = financeAccountId;
        InvTransactionObj1.Cost_Basis__c = cost;
        InvTransactionObj1.Buy_Amount__c = cost;                                                   
        InvTransactionObj1.shares_quantity__c = cost/price;
        InvTransactionObj1.Purchase_Price__c = price;
        InvTransactionObj1.Securities__c = securityRecordId;
        InvTransactionObj1.Status__c = 'Processing';
        InvTransactionObj1.Initiator_Type__c = 'Beneficiary/Age Update';
        InvTransactionObj1.Transaction_Date__c = System.now();
        InvTransactionList.add(InvTransactionObj1);

        Investment_Transaction__c  InvTransactionObj2 = new Investment_Transaction__c();
        InvTransactionObj2.Action_Type__c = 'Buy';
        InvTransactionObj2.Financial_Account__c = financeAccountId;
        InvTransactionObj2.Cost_Basis__c = cost;
        InvTransactionObj2.Buy_Amount__c = cost;                                                   
        InvTransactionObj2.shares_quantity__c = cost/price;
        InvTransactionObj2.Purchase_Price__c = price;
        InvTransactionObj2.Securities__c = securityRecordId;
        InvTransactionObj2.Status__c = 'Pending';
        InvTransactionObj2.Initiator_Type__c = 'Beneficiary/Age Update';
        InvTransactionObj2.Transaction_Date__c = System.now();
        InvTransactionList.add(InvTransactionObj2);  

        Investment_Transaction__c  InvTransactionObj3 = new Investment_Transaction__c();
        InvTransactionObj3.Action_Type__c = 'Sell';
        InvTransactionObj3.Financial_Account__c = financeAccountId;
        InvTransactionObj3.Cost_Basis__c = cost;
        InvTransactionObj3.Buy_Amount__c = cost;                                                   
        InvTransactionObj3.shares_quantity__c = cost/price;
        InvTransactionObj3.Purchase_Price__c = price;
        InvTransactionObj3.Securities__c = securityRecordId;
        InvTransactionObj3.Status__c = 'Pending';
        InvTransactionObj3.Initiator_Type__c = 'Beneficiary/Age Update';
        InvTransactionObj3.Transaction_Date__c = System.now();
        InvTransactionList.add(InvTransactionObj3);

        Investment_Transaction__c  InvTransactionObj4 = new Investment_Transaction__c();
        InvTransactionObj4.Action_Type__c = 'Sell';
        InvTransactionObj4.Financial_Account__c = financeAccountId;
        InvTransactionObj4.Cost_Basis__c = cost;
        InvTransactionObj4.shares_quantity__c = cost/price;
        InvTransactionObj4.Purchase_Price__c = price;
        InvTransactionObj4.Securities__c = securityRecordId;
        InvTransactionObj4.Status__c = 'Pending';
        InvTransactionObj4.Initiator_Type__c = 'Beneficiary/Age Update';
        InvTransactionObj4.Transaction_Date__c = System.now();
        InvTransactionList.add(InvTransactionObj4);

        Investment_Transaction__c  InvTransactionObj5 = new Investment_Transaction__c();
        InvTransactionObj5.Action_Type__c = 'Sell';
        InvTransactionObj5.Financial_Account__c = financeAccountId;
        InvTransactionObj5.Cost_Basis__c = cost;
        InvTransactionObj5.Buy_Amount__c = cost;                                                   
        InvTransactionObj5.shares_quantity__c = cost/price;
        InvTransactionObj5.Purchase_Price__c = price;
        InvTransactionObj5.Securities__c = securityRecordId;
        InvTransactionObj5.Status__c = 'Complete';
        InvTransactionObj5.Initiator_Type__c = 'Beneficiary/Age Update';
        InvTransactionObj5.Transaction_Date__c = System.now();
        InvTransactionList.add(InvTransactionObj5);

        Investment_Transaction__c  InvTransactionObj6 = new Investment_Transaction__c();
        InvTransactionObj6.Action_Type__c = 'Sell';
        InvTransactionObj6.Financial_Account__c = financeAccountId;
        InvTransactionObj6.Cost_Basis__c = cost;
        InvTransactionObj6.shares_quantity__c = cost/price;
        InvTransactionObj6.Purchase_Price__c = price;
        InvTransactionObj6.Securities__c = securityRecordId;
        InvTransactionObj6.Status__c = 'Complete';
        InvTransactionObj6.Initiator_Type__c = 'Beneficiary/Age Update';
        InvTransactionObj6.Transaction_Date__c = System.now();
        InvTransactionList.add(InvTransactionObj6);

        insert InvTransactionList;
        return InvTransactionList;

    }

    public static List<Security_Price_History__c> createPriceHistoryRecord(Id securityRecordId){
        List<Security_Price_History__c> historyRecordList = new List<Security_Price_History__c>();
        //Current
        Security_Price_History__c historyRecord = new Security_Price_History__c();
        historyRecord.Price__c = 1000;
        historyRecord.Price_Date__c = Date.today(); 
        historyRecord.Symbol__c = securityRecordId;
        historyRecordList.add(historyRecord);

        //3 Month
        Security_Price_History__c historyRecord1 = new Security_Price_History__c();
        historyRecord1.Price__c = 1000;
        historyRecord1.Price_Date__c = Date.today().addDays(-90); 
        historyRecord1.Symbol__c = securityRecordId;
        historyRecordList.add(historyRecord1);

        //1 year
        Security_Price_History__c historyRecord2 = new Security_Price_History__c();
        historyRecord2.Price__c = 1000;
        historyRecord2.Price_Date__c = Date.today().addDays(-365); 
        historyRecord2.Symbol__c = securityRecordId;
        historyRecordList.add(historyRecord2);

        //3 year
        Security_Price_History__c historyRecord3 = new Security_Price_History__c();
        historyRecord3.Price__c = 1000;
        historyRecord3.Price_Date__c = Date.today().addDays(-1095); 
        historyRecord3.Symbol__c = securityRecordId;
        historyRecordList.add(historyRecord3);

        //5 year
        Security_Price_History__c historyRecord4 = new Security_Price_History__c();
        historyRecord4.Price__c = 1000;
        historyRecord4.Price_Date__c = Date.today().addDays(-30); 
        historyRecord4.Symbol__c = securityRecordId;
        historyRecordList.add(historyRecord4);

        //1 Month
        Security_Price_History__c historyRecord5 = new Security_Price_History__c();
        historyRecord5.Price__c = 1000;
        historyRecord5.Price_Date__c = Date.today().addDays(-30); 
        historyRecord5.Symbol__c = securityRecordId;
        historyRecordList.add(historyRecord5);

        insert historyRecordList;
        return historyRecordList;
    }

    public static Transfer_Fund__c createTransferFundRecord(Id finAccountId,Id cashAccountId){ 
        Id transferRecordTypeId = Schema.SObjectType.Transfer_Fund__c.getRecordTypeInfosByDeveloperName().get('Transfer').getRecordTypeId();

        Transfer_Fund__c transferFund = new Transfer_Fund__c();        
        transferFund.Financial_Account_Investment__c = finAccountId;   
        transferFund.Financial_Account_Cash__c = cashAccountId;        
        transferFund.Transfer_Amount__c = 100;
        transferFund.recordTypeId = transferRecordTypeId;
        transferFund.Withdrawal_Cost_Basis__c = 1000;
        transferFund.Processed_Date__c = DateTime.now();
        transferFund.Status__c = 'Processing';
        insert transferFund; 
        return transferFund;
    }
    /*public static void createAgeBasedPortfolioData1(){
        

        Product2  p = new Product2();
		p.Name = 'SecondChoice1';
		insert p; 

        Contract contract = new Contract();
		contract.Name = 'Final';
		contract.AccountId = newAccount.Id;
		insert contract;
        
        List<FinServ__FinancialAccountTransaction__c> ListRollup = new List<FinServ__FinancialAccountTransaction__c>();
            
        tempFin_txn.FinServ__Amount__c = 100;
        tempFin_txn.FinServ__PostDate__c = DateTime.now();
        tempFin_txn.FinServ__TransactionType__c = 'Debit';
        tempFin_txn.FinServ__TransactionSubtype__c = 'Withdrawal';
        tempFin_txn.Source_Type__c = 'ACH';
        tempFin_txn.FinServ__FinancialAccount__c = tempcashaccount.Id;
        tempFin_txn.FinServ__TransactionStatus__c = 'Posted';
        tempFin_txn.FinServ__TransactionDate__c = DateTime.now();

        ListRollup.add(tempFin_txn);
        system.debug('list size: '+ListRollup.size());
        if(ListRollup.size()>0)
        insert(ListRollup);

    }*/
}