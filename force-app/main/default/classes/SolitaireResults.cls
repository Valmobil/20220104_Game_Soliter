/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-25-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global with sharing class SolitaireResults {
    
    @AuraEnabled
    public static String getResults(String gameId) {
        System.debug('Get Result. GameId: ' + gameId);
        List<Solitair_Metadata__c> boards = [select id, Solitair_Game_Id__c, value__c from Solitair_Metadata__c where Solitair_Game_Id__c = :gameId];
        List<Result> results = new List<Result>();
        Integer index = 0;
        for (Solitair_Metadata__c boardDb : boards) {
           Result res = new Result();
           Board board = (Board) JSON.deserialize(boardDb.value__c, Board.class);
           res.id = boardDb.id;
           res.value = board.lastMove;
           results.add(res);
        }
        return JSON.serialize(results);
    }

    class Result {
        String id;
        String value;
    }
}