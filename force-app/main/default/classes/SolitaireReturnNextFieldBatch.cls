/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-19-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class SolitaireReturnNextFieldBatch 
    implements Database.Batchable<sObject>, Database.Stateful {
    private String query;
    private Id gameId;
    private Id boardId;
    private String cardAddress;
    private String cardValue;
    private Decimal maxScore;

    public SolitaireReturnNextFieldBatch(String query, Id gameId, Id boardId, String cardAddress, String cardValue, Decimal maxScore) {
        this.query = query;
        this.gameId = gameId;
        this.boardId = boardId;
        this.cardAddress = cardAddress;
        this.cardValue = cardValue;
        this.maxScore = maxScore;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(this.query);
    }

    public void execute(Database.BatchableContext bc, List<Solitair_Metadata__c> scope){
        // process each batch of records
        SolitaireReturnNextField.startQuableBoardVarintsCalculation(scope, this.boardId, this.cardAddress, this.cardValue);
    }

    public void finish(Database.BatchableContext bc){

        SolitaireResults.startResultBatch(this.gameId, this.boardId);

        // AsyncApexJob job = [SELECT Id, Status, NumberOfErrors,
        //     JobItemsProcessed,
        //     TotalJobItems, CreatedBy.Email
        //     FROM AsyncApexJob
        //     WHERE Id = :bc.getJobId()];
        // // call some utility to send email
        // EmailUtils.sendMessage(job, 'recordsProcessed');
    }
}