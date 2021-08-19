public with sharing class InsurancePolicyCoverageTriggerHandler {
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;

    public InsurancePolicyCoverageTriggerHandler(boolean isExecuting, integer size) {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    set < id > productIds = new set < id > ();

    public void OnBeforeInsert(List < InsurancePolicyCoverage > newCoverage) {

        for (InsurancePolicyCoverage ipc: newCoverage) {
            productIds.add(ipc.Product__c);
        }

        if (!productIds.isEmpty()) {
            map < id, product2 > productList = new map < id, product2 > ([SELECT Id,
                Name,
                IsActive,
                Dormitory__c,
                Local_Lower__c,
                Local_Upper__c,
                Local__c,
                Number_of_Years__c,
                TDF__c,
                Tuition_Lower__c,
                Tuition_Upper__c,
                Tuition__c
                FROM Product2
                WHERE id IN: productIds
                AND IsActive = true
            ]);

            for (InsurancePolicyCoverage ipc: newCoverage) {
                product2 pr = productList.get(ipc.Product__c);

                if (ipc.category == 'University' && ipc.Coverage_Type__c == 'Tuition') {
                    ipc.Tuition__c = pr.Tuition__c;

                } else if (ipc.category == 'University' && ipc.Coverage_Type__c == 'Local') {
                    ipc.Local__c = pr.Local__c;

                } else if (ipc.category == 'University' && ipc.Coverage_Type__c == 'TDF') {
                    ipc.TDF__c = pr.TDF__c;

                } else if (ipc.category == 'College' && ipc.Coverage_Type__c == 'Tuition' && pr.Number_of_Years__c < 3) {
                    ipc.Tuition_Lower__c = pr.Tuition_Lower__c;

                } else if (ipc.category == 'College' && ipc.Coverage_Type__c == 'Local' && pr.Number_of_Years__c < 3) {
                    ipc.Local_Lower__c = pr.Local_Lower__c;

                } else if (ipc.category == 'College' && ipc.Coverage_Type__c == 'Tuition' && pr.Number_of_Years__c > 2) {
                    ipc.Tuition_Lower__c = pr.Tuition_Lower__c;
                    ipc.Tuition_Upper__c = pr.Tuition_Upper__c;

                } else if (ipc.category == 'College' && ipc.Coverage_Type__c == 'Local' && pr.Number_of_Years__c > 2) {
                    ipc.Local_Lower__c = pr.Local_Lower__c;
                    ipc.Local_Upper__c = pr.Local_Upper__c;

                } else if (ipc.category == 'Bundled' && ipc.Coverage_Type__c == 'Tuition') {
                    ipc.Tuition__c = pr.Tuition__c;
                    ipc.Tuition_Lower__c = pr.Tuition_Lower__c;
                    ipc.Tuition_Upper__c = pr.Tuition_Upper__c;

                }else if (ipc.category == 'Bundled' && ipc.Coverage_Type__c == 'Local') {
                    ipc.Local__c = pr.Local__c;
                    ipc.Local_Lower__c = pr.Local_Lower__c;
                    ipc.Local_Upper__c = pr.Local_Upper__c;
                
                }else if (ipc.category == 'Bundled' && ipc.Coverage_Type__c == 'TDF') {
                    ipc.TDF__c = pr.TDF__c;
                
                }else if (ipc.category == 'Dormitory') {
                    ipc.Dormitory__c = pr.Dormitory__c;
                }
            }
        }
    }

    public void OnAfterInsert(List < InsurancePolicyCoverage > newCoverage) {}

    public void OnBeforeUpdate(List < InsurancePolicyCoverage > newCoverage, List < InsurancePolicyCoverage > oldCoverage, Map < ID, InsurancePolicyCoverage > newCoverageMap, Map < ID, InsurancePolicyCoverage > oldCoverageMap) {}

    public void OnAfterUpdate(List < InsurancePolicyCoverage > newCoverage, List < InsurancePolicyCoverage > oldCoverage, Map < ID, InsurancePolicyCoverage > newCoverageMap, Map < ID, InsurancePolicyCoverage > oldCoverageMap) {}
}