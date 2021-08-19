public with sharing class claimTriggerHandler {
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;

    public claimTriggerHandler(boolean isExecuting, integer size) {
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    public void OnBeforeInsert(List < claim > newClaim) {
        system.debug('Claim Trigger On Before Insert');
    }

    public void OnAfterInsert(List < claim > newClaim) {
        system.debug('Claim Trigger On After Insert');
    }

    public void OnBeforeUpdate(List < claim > newClaim, List < claim > oldClaim, Map < ID, claim > newClaimMap, Map < ID, claim > oldClaimMap) {
        system.debug('Claim Trigger On Before Update ');
    }

    public void OnAfterUpdate(List < claim > newClaim, List < claim > oldClaim, Map < ID, claim > newClaimMap, Map < ID, claim > oldClaimMap) {
        system.debug('Claim Trigger On After Update ');
        set < id > claimId = new set < id > ();
        map < id, id > mapInsurancePolicyClaimId = new map < id, id > ();
        map < id, list < InsurancePolicyCoverage >> mapClaimInsurancePolicyCoverage = new map < id, list < InsurancePolicyCoverage >> ();
        set < id > insuranceCoverageId = new set < id > ();
        //map < id, decimal > claimActualUnit = new map < id, decimal > ();
        map < id, claim > claimActualUnit = new map < id, claim > ();

        for (claim c: newClaim) {
            if (oldClaimMap.get(c.id).status != newClaimMap.get(c.id).status && c.status == 'Granted') {
                claimId.add(c.id);
                //claimActualUnit.put(c.id, c.Actual_Unit__c);
                claimActualUnit.put(c.id, c);
            }
        }

        if (!claimId.isEmpty()) {
            list < ClaimItem > cItem = [SELECT Id,
                InsurancePolicyCoverageId,
                ClaimId
                FROM ClaimItem
                WHERE ClaimId IN: claimId
            ];
            system.debug('cItem....'+cItem);

            if (!cItem.isEmpty()) {
                for (claimItem ct: cItem) {
                    insuranceCoverageId.add(ct.InsurancePolicyCoverageId);
                    mapInsurancePolicyClaimId.put(ct.InsurancePolicyCoverageId, ct.ClaimId);
                }
                system.debug('insuranceCoverageId....'+insuranceCoverageId);

                if (!insuranceCoverageId.isEmpty()) {
                    list < InsurancePolicyCoverage > insuranceCovgList = [SELECT Id,
                        Name,
                        Category,
                        Local__c,
                        Local_Upper__c,
                        Local_Lower__c,
                        Tuition__c,
                        Tuition_Upper__c,
                        Tuition_Lower__c,
                        TDF__c,
                        Product__c,
                        Number_of_Years__c,
                        Dormitory__c,
                        Coverage_Type__c
                        FROM InsurancePolicyCoverage
                        WHERE Id IN: insuranceCoverageId
                    ];

                    if (!insuranceCovgList.isEmpty()) {
                        for (InsurancePolicyCoverage ipc: insuranceCovgList) {
                            if (mapClaimInsurancePolicyCoverage.containsKey(mapInsurancePolicyClaimId.get(ipc.id))) {
                                list < InsurancePolicyCoverage > tempList = mapClaimInsurancePolicyCoverage.get(mapInsurancePolicyClaimId.get(ipc.id));
                                tempList.add(ipc);
                                mapClaimInsurancePolicyCoverage.put(mapInsurancePolicyClaimId.get(ipc.id), tempList);
                            } else {
                                mapClaimInsurancePolicyCoverage.put(mapInsurancePolicyClaimId.get(ipc.id), new list < InsurancePolicyCoverage > {
                                    ipc
                                });
                            }
                        }
                        system.debug('mapClaimInsurancePolicyCoverage....'+mapClaimInsurancePolicyCoverage);
                    }

                    if (!claimId.isEmpty()) {
                        List < InsurancePolicyCoverage > updateInsuranceCoverageList = new list < InsurancePolicyCoverage > ();
                        for (id cm: claimId) {
                            list < InsurancePolicyCoverage > tempList = mapClaimInsurancePolicyCoverage.get(cm);
                        system.debug('tempList....'+tempList);

                        for (InsurancePolicyCoverage ic: tempList) {

                            if(ic.Coverage_Type__c == 'Tuition'){

                                if(claimActualUnit.get(cm).Tuition__c != null){
                                    if (claimActualUnit.get(cm).Tuition__c < ic.Tuition__c) {
                                        ic.Tuition__c = ic.Tuition__c - claimActualUnit.get(cm).Tuition__c;
                                    }else {
                                        ic.Tuition__c = 0;
                                    }
                                }

                                if(claimActualUnit.get(cm).Tuition_Lower__c != null){
                                    if (claimActualUnit.get(cm).Tuition_Lower__c < ic.Tuition_Lower__c) {
                                        ic.Tuition_Lower__c = ic.Tuition_Lower__c - claimActualUnit.get(cm).Tuition_Lower__c;
                                    }else {
                                        ic.Tuition_Lower__c = 0;
                                    }
                                }
    
                                if(claimActualUnit.get(cm).Tuition_Upper__c != null){
                                    if (claimActualUnit.get(cm).Tuition_Upper__c < ic.Tuition_Upper__c) {
                                        ic.Tuition_Upper__c = ic.Tuition_Upper__c - claimActualUnit.get(cm).Tuition_Upper__c;
                                    }else {
                                        ic.Tuition_Upper__c = 0;
                                    }
                                }
                                updateInsuranceCoverageList.add(ic);
                            }

                            if(ic.Coverage_Type__c == 'Local'){

                                if(claimActualUnit.get(cm).Local__c != null){
                                    if (claimActualUnit.get(cm).Local__c < ic.Local__c) {
                                        ic.Local__c = ic.Local__c - claimActualUnit.get(cm).Local__c;
                                    }else {
                                        ic.Local__c = 0;
                                    }
                                }

                                if(claimActualUnit.get(cm).Local_Lower__c != null){
                                    if (claimActualUnit.get(cm).Local_Lower__c < ic.Local_Lower__c) {
                                        ic.Local_Lower__c = ic.Local_Lower__c - claimActualUnit.get(cm).Local_Lower__c;
                                    }else {
                                        ic.Local_Lower__c = 0;
                                    }
                                }
    
                                if(claimActualUnit.get(cm).Local_Upper__c != null){
                                    if (claimActualUnit.get(cm).Local_Upper__c < ic.Local_Upper__c) {
                                        ic.Local_Upper__c = ic.Local_Upper__c - claimActualUnit.get(cm).Local_Upper__c;
                                    }else {
                                        ic.Local_Upper__c = 0;
                                    }
                                }
                                updateInsuranceCoverageList.add(ic);
                            }

                            if(ic.Coverage_Type__c == 'TDF'){
                                if(claimActualUnit.get(cm).TDF__C != null){
                                    if (claimActualUnit.get(cm).TDF__C < ic.TDF__C) {
                                        ic.TDF__C = ic.TDF__C - claimActualUnit.get(cm).TDF__C;
                                    }else {
                                        ic.TDF__C = 0;
                                    }
                                }
                                updateInsuranceCoverageList.add(ic);
                            }

                            if(ic.Coverage_Type__c == 'Dorm'){
                                if(claimActualUnit.get(cm).Dormitory__c != null){
                                    if (claimActualUnit.get(cm).Dormitory__c < ic.Dormitory__c) {
                                        ic.Dormitory__c = ic.Dormitory__c - claimActualUnit.get(cm).Dormitory__c;
                                    }else {
                                        ic.Dormitory__c = 0;
                                    }
                                }
                                updateInsuranceCoverageList.add(ic);
                            }
                        }

                           /* for (InsurancePolicyCoverage ic: tempList) {
                                ic.Restrict_Update__c = true;
                                if (ic.Category == 'University') {
                                    if(ic.Tuition__c != null){
                                        system.debug('in Tuition...');
                                        if (claimActualUnit.get(cm).Tuition__c < ic.Tuition__c) {
                                            ic.Tuition__c = ic.Tuition__c - claimActualUnit.get(cm).Tuition__c;
                                        }else {
                                            ic.Tuition__c = 0;
                                        }
                                        //updateInsuranceCoverageList.add(ic);
                                    } else if(ic.Local__c != null){
                                        system.debug('in local...');
                                        if (claimActualUnit.get(cm).Local__c < ic.Local__c) {
                                            ic.Local__c = ic.Local__c - claimActualUnit.get(cm).Local__c;
                                        }else {
                                            ic.Local__c = 0;
                                        }
                                       // updateInsuranceCoverageList.add(ic);
                                    }else if(ic.TDF__c  !=null){
                                        if (claimActualUnit.get(cm).TDF__c < ic.TDF__c) {
                                            ic.TDF__c = ic.TDF__c - claimActualUnit.get(cm).TDF__c;
                                        }else {
                                            ic.TDF__c = 0;
                                        }
                                   }
                                   updateInsuranceCoverageList.add(ic);
                                } else if (ic.Category == 'College' && ic.Number_of_Years__c < 3) {
                                    if(ic.Tuition_Lower__c!= null){
                                        if (ic.Tuition_Lower__c > claimActualUnit.get(cm).Tuition_Lower__c) {
                                            ic.Tuition_Lower__c = ic.Tuition_Lower__c - claimActualUnit.get(cm).Tuition_Lower__c;
                                        }else {
                                            ic.Tuition_Lower__c = 0;
                                        }
                                        //updateInsuranceCoverageList.add(ic);
                                    } else if(ic.Local_Lower__c != null){
                                        if (ic.Local_Lower__c > claimActualUnit.get(cm).Local_Lower__c) {
                                            ic.Local_Lower__c = ic.Local_Lower__c - claimActualUnit.get(cm).Local_Lower__c;
                                        }else {
                                            ic.Local_Lower__c = 0;
                                        }
                                    }
                                    updateInsuranceCoverageList.add(ic);

                                } else if (ic.Category == 'College' && ic.Number_of_Years__c > 2) {
                                    if(ic.Tuition_Lower__c != null) {
                                        if (ic.Tuition_Lower__c > 0 && ic.Tuition_Lower__c > claimActualUnit.get(cm).Tuition_Lower__c) {

                                            ic.Tuition_Lower__c = ic.Tuition_Lower__c - claimActualUnit.get(cm).Tuition_Lower__c;

                                        } else if (ic.Tuition_Lower__c > 0 && ic.Tuition_Lower__c < claimActualUnit.get(cm).Tuition_Lower__c) {
                                            decimal tempVar = claimActualUnit.get(cm).Tuition_Lower__c - ic.Tuition_Lower__c;
                                            ic.Tuition_Lower__c = 0;

                                            if (tempVar < ic.Tuition_Upper__c) {
                                                ic.Tuition_Upper__c = ic.Tuition_Upper__c - tempVar;
                                            } else {
                                                ic.Tuition_Upper__c = 0;
                                            }
                                        } 
                                        //updateInsuranceCoverageList.add(ic);

                                    }else if(ic.Local_Lower__c != null) {
                                        if (ic.Local_Lower__c > 0 && ic.Local_Lower__c > claimActualUnit.get(cm).Local_Lower__c) {

                                            ic.Local_Lower__c = ic.Local_Lower__c - claimActualUnit.get(cm).Local_Lower__c;

                                        }else if (ic.Local_Lower__c > 0 && ic.Local_Lower__c < claimActualUnit.get(cm).Local_Lower__c) {
                                            decimal tempVar = claimActualUnit.get(cm).Local_Lower__c - ic.Local_Lower__c;
                                            ic.Local_Lower__c = 0;
                                            if (tempVar < ic.Local_Upper__c) {
                                                ic.Local_Upper__c = ic.Local_Upper__c - tempVar;
                                            }else {
                                                ic.Local_Upper__c = 0;
                                            }
                                        } 
                                        //updateInsuranceCoverageList.add(ic);
                                    }
                                    updateInsuranceCoverageList.add(ic);
                                } else if (ic.Category == 'Bundled') {
                                  

                                } else if (ic.Category == 'Dorm') {
                                    if(ic.Dormitory__c != null){
                                        ic.Dormitory__c = ic.Dormitory__c - claimActualUnit.get(cm).Dormitory__c;
                                        updateInsuranceCoverageList.add(ic);
                                    }
                                }

                            }*/
                        }
                        System.debug('updateInsuranceCoverageList....'+updateInsuranceCoverageList);
                        if (!updateInsuranceCoverageList.isEmpty()) {
                            update updateInsuranceCoverageList;
                        }
                    }


                }
            }

        }
    }


}