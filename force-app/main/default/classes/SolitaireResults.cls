/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-13-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global with sharing class SolitaireResults {
    
    @AuraEnabled
    public static String getResults(String boardId) {
        System.debug('Get Result. BoardId: ' + boardId);
        List<Solitair_Metadata__c> gameIds = [select Solitair_Game_Id__c from Solitair_Metadata__c where id = :boardId];
        System.debug('GameIds: ' + gameIds);
        if (gameIds.size() > 0) {
            Id gameId = gameIds.get(0).Solitair_Game_Id__c;
            
            List<Solitair_Metadata__c> boards = [select id, Solitair_Game_Id__c, value__c, completed__c from Solitair_Metadata__c where Solitair_Game_Id__c = :gameId];
            
            Set<String> minPathIds = calculateMinPath(boards, boardId);

            // SolitaireSolver.printList('Boards before sort:', boards);
            List<Result> results = new List<Result>();
            Integer index = 0;
            for (Solitair_Metadata__c boardDb : boards) {
            Result res = new Result();
            Board board = (Board) JSON.deserialize(boardDb.value__c, Board.class);
            res.id = boardDb.id;
            res.value = board.lastMove;
            res.completed = boardDb.completed__c;
            res.minPath = minPathIds.contains(boardDb.id);
            results.add(res);
            }
            results.sort();
            
            SolitaireSolver.printList('Boards after sort:', results);
            return JSON.serialize(results);
        }
        return null;
    }

    private static Set<String> calculateMinPath(List<Solitair_Metadata__c> boardsDb, String boardId) {
        Set<String> ids = new Set<String>();
        ids.add(boardId);
        List<Board> boards = new List<Board>();

        //create list of boards
        // List<String> temp = new List<String>();
        for (Solitair_Metadata__c boardDb : boardsDb) {
            Result res = new Result();
            Board board = (Board) JSON.deserialize(boardDb.value__c, Board.class);
            board.boardId = boardDb.id;
            boards.add(board);
            // temp.add(boardDb.id + '_ _' + board.parentId);
        }
        // System.debug('BoardId: ' + boardId);
        // SolitaireSolver.printList('Board list for min path calulation:', temp);
        Boolean found = false;
        do {
            found = false;
            for (Integer i = 0; i < boards.size(); i++) {
                Board board = boards.get(i);
                found = ids.contains(board.boardId);
                if (found) {
                    ids.add(board.parentId);
                    found = true;
                    boards.remove(i);
                    break;
                }
            }
        } while (found);
        SolitaireSolver.printList('Path ids: ', ids);
        return ids;
        
    }

    public class Result  implements Comparable {
        String id;
        String value;
        Boolean completed;
        Boolean minPath;

    public Integer compareTo(Object compareTo) {
            // Cast argument to OpportunityWrapper
            Result compareToOppy = (Result)compareTo;
    
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