public with sharing class CaseTriggerHandler {

    public static void handleAfter(List<Case> newList, Map<Id, Case> oldMap) {
        List<Task> tasksToInsert = new List<Task>();
        Set<Id> accountIds = new Set<Id>();

        for (Case cs : newList) {
            Case oldCs = oldMap != null ? oldMap.get(cs.Id) : null;

            // Condition: High Priority + New
            Boolean isNewHigh = (cs.Priority == 'High' && cs.Status == 'New');
            Boolean wasNewHigh = oldCs != null && oldCs.Priority == 'High' && oldCs.Status == 'New';

            if (isNewHigh && !wasNewHigh) {
                // Create Task for Case Owner
                tasksToInsert.add(new Task(
                    WhatId = cs.Id,
                    OwnerId = cs.OwnerId,
                    Subject = 'Follow up on High Priority Case',
                    Status = 'Not Started',
                    Priority = 'High'
                ));
            }

            if (cs.AccountId != null) {
                accountIds.add(cs.AccountId);
            }
        }

        if (!tasksToInsert.isEmpty()) insert tasksToInsert;
        if (!accountIds.isEmpty()) {
            updateAccountsHealth(accountIds);
        }
    }

    private static void updateAccountsHealth(Set<Id> accountIds) {
        Map<Id, Integer> caseCountMap = new Map<Id, Integer>();

        List<AggregateResult> caseList = [
            SELECT AccountId accId, COUNT(Id) caseCount
            FROM Case
            WHERE AccountId IN :accountIds
            AND Priority = 'High' AND Status != 'Closed'
            GROUP BY AccountId
        ];

        for (AggregateResult ar : caseList) {
            caseCountMap.put((Id)ar.get('accId'), (Integer)ar.get('caseCount'));
        }

        List<Account> accToUpdate = new List<Account>();
        for (Id accId : caseCountMap.keySet()) {
            accToUpdate.add(new Account(
                Id = accId,
                High_Priority_Cases__c = caseCountMap.get(accId),
                Health__c = caseCountMap.get(accId) > 5 ? 'Critical' : 'Good'
            ));
        }

        if (!accToUpdate.isEmpty()) update accToUpdate;
    }
}