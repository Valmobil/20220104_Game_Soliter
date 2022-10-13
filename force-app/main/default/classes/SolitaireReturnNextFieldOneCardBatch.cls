/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-19-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class SolitaireReturnNextFieldOneCardBatch 
implements Database.Batchable<sObject>, Database.Stateful {
    
    private String query;
    private Id gameId;
    private Id boardId;
    private String cardAddress;
    private String cardValue;

    public SolitaireReturnNextFieldOneCardBatch(String query, Id gameId, Id boardId, String cardAddress, String cardValue) {
        this.query = query;
        this.gameId = gameId;
        this.boardId = boardId;
        this.cardAddress = cardAddress;
        this.cardValue = cardValue;
    }

    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(this.query);
    }

    public void execute(Database.BatchableContext bc, List<Solitair_Metadata__c> scope){
        //SolitaireSolver.printList('List of boards for one card update:', scope);
        // process each batch of records
        SolitaireReturnNextField.updateAllAlligibleBoardsWithNewCard(scope, gameId, this.boardId, this.cardAddress, this.cardValue);
    }

    public void finish(Database.BatchableContext bc){
        SolitaireReturnNextField.startBoardsVariantsCalculation(gameId, this.boardId, this.cardAddress, this.cardValue);
    }
}