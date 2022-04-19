/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-19-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global with sharing class SolitaireResults {
    
    @AuraEnabled
    public static String getResults(String boardId) {
        //System.debug('Get Result. BoardId: ' + boardId);
        List<Solitair_Metadata__c> gameIds = [select Solitair_Game_Id__c from Solitair_Metadata__c where id = :boardId];
        //System.debug('GameIds: ' + gameIds);
        Id gameId = gameIds.get(0).Solitair_Game_Id__c;
        
        generateResultTable(gameId, boardId);
        
        List<Solitair_Result__c> results = [select board_id__c, parent_board_id__c, last_move__c, completed__c, min_path__c 
            from Solitair_Result__c Order by last_move__c desc ];
        //SolitaireSolver.printList('Boards after sort:', results);
        
        return JSON.serialize(results);
    }

    private static void generateResultTable(String gameId, String boardId) {
        
        List<Solitair_Metadata__c> boards = [select id, Solitair_Game_Id__c, value__c, completed__c from Solitair_Metadata__c where Solitair_Game_Id__c = :gameId];
        
        //Set<String> minPathIds = calculateMinPath(boards, boardId);
        Set<String> minPathIds = new Set<String>();

        // SolitaireSolver.printList('Boards before sort:', boards);
        List<Solitair_Result__c> results = new List<Solitair_Result__c>();
        Integer index = 0;
        for (Solitair_Metadata__c boardDb : boards) {
            Solitair_Result__c res = new Solitair_Result__c();
            Board board = (Board) JSON.deserialize(boardDb.value__c, Board.class);
            res.board_id__c = boardDb.id;
            res.parent_board_id__c = board.parentId;
            res.last_move__c = board.lastMove;
            res.completed__c = boardDb.completed__c;
            res.min_Path__c = minPathIds.contains(boardDb.id);
            results.add(res);
        }
        List<Solitair_Result__c> res = [select id from Solitair_Result__c];
        delete res;
        
        insert results;
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
        //SolitaireSolver.printList('Path ids: ', ids);
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