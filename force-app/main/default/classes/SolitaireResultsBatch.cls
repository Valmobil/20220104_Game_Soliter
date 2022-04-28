/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-26-2022
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
    }
}
