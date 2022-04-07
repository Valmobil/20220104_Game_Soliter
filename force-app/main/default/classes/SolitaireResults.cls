/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-06-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global with sharing class SolitaireResults {
    
    @AuraEnabled
    public static String getResults(String gameId) {
        System.debug('Get Result. GameId: ' + gameId);
        List<Solitair_Metadata__c> boards = [select id, Solitair_Game_Id__c, value__c, completed__c from Solitair_Metadata__c where Solitair_Game_Id__c = :gameId];
        
        SolitaireSolver.printList('Boards before sort:', boards);
        List<Result> results = new List<Result>();
        Integer index = 0;
        for (Solitair_Metadata__c boardDb : boards) {
           Result res = new Result();
           Board board = (Board) JSON.deserialize(boardDb.value__c, Board.class);
           res.id = boardDb.id;
           res.value = board.lastMove;
           res.completed = boardDb.completed__c;
           results.add(res);
        }
        results.sort();
        SolitaireSolver.printList('Boards after sort:', results);
        return JSON.serialize(results);
    }

    public class Result  implements Comparable {
        String id;
        String value;
        Boolean completed;

    public Integer compareTo(Object compareTo) {
            // Cast argument to OpportunityWrapper
            Result compareToOppy = (Result)compareTo;
    
            System.debug('CompareTo');
            System.debug(compareToOppy.value);
            System.debug(this.value);
            String val0 = this.value;
            String val1 = compareToOppy.value;
            if (this.value == null) {
                val0 = '0.0';
            }
            if (compareToOppy.value == null) {
                val1 = '0.0';
            }
            // The return value of 0 indicates that both elements are equal.
            Integer returnValue = 0;
            Integer q0 = Integer.valueOf(val0.SubStringBefore('.'));
            Integer q1 = Integer.valueOf(val1.SubStringBefore('.'));
            if (q0 > q1) {
                //sort by level first
                // Set return value to a positive value.
                returnValue = -1;
            } else if (q0 < q1) {
                // Set return value to a negative value.
                returnValue = 1;
            } else if (q0 == q1) {
                //sort by string
                String s0 = val0.SubStringAfter('.');
                String s1 = val1.SubStringAfter('.');
                if (s0 > s1) {
                    // Set return value to a positive value.
                    returnValue = -1;
                } else if (s0 < s1) {
                    // Set return value to a negative value.
                    returnValue = 1;
                }
            }
            return returnValue;       
        }
    }
}