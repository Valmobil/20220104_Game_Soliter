/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-20-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class SolitaireResultsBatch 
    implements Database.Batchable<sObject>, Database.Stateful {
        private String query;
        private Id gameId;
        private Id boardId;

    public SolitaireResultsBatch(String query, Id gameId, Id boardId) {
        this.query = query;
        this.gameId = gameId;
        this.boardId = boardId;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(this.query);
    }

    public void execute(Database.BatchableContext bc, List<Solitair_Metadata__c> scope){

        // process each batch of records
        SolitaireResults.generateResultTable(scope, this.gameId, this.boardId);
    }

    public void finish(Database.BatchableContext bc){
       //add event for page refresh
    //    List<SolitaireGameUpdate__e> inkEvents = new List<SolitaireGameUpdate__e>();
// inkEvents.add(new Low_Ink__e(Printer_Model__c='XZO-5', Serial_Number__c='12345', 
//               Ink_Percentage__c=0.2));
// inkEvents.add(new Low_Ink__e(Printer_Model__c='MN-123', Serial_Number__c='10013', 
//               Ink_Percentage__c=0.15));


// Call method to publish events
// List<Database.SaveResult> results = EventBus.publish(inkEvents);
    }
}
