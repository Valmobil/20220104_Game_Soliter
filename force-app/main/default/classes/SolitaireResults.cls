/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-20-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global with sharing class SolitaireResults {
    
    @AuraEnabled(cacheable=false)
    public static List<Solitair_Result__c> getResults(String boardId) {
        //System.debug('Get Result. BoardId: ' + boardId);
        List<Solitair_Metadata__c> gameIds = [select Solitair_Game_Id__c from Solitair_Metadata__c where id = :boardId];
        //System.debug('GameIds: ' + gameIds);
        Id gameId = gameIds.get(0).Solitair_Game_Id__c;
        
        //generateResultTable(gameId, boardId);
        
        List<Solitair_Result__c> results = [select board_id__c, parent_board_id__c, last_move__c, completed__c, min_path__c 
            from Solitair_Result__c Order by Result_Sorting__c desc];
        //SolitaireSolver.printList('Boards after sort:', results);

        calculateMinPath(results, boardId);

        System.debug('Result: ');
        System.debug(results);

        if (results == null) {
            results = new List<Solitair_Result__c>();
        }

        return results;
    }

    public static void startResultBatch(String gameId, String boardId) {
        //clear result table
        List<Solitair_Result__c> res = [select id from Solitair_Result__c];
        delete res;
        
        //generate contant of result table
        String queueary = 'select id, Solitair_Game_Id__c, value__c, completed__c ' + 
            'from Solitair_Metadata__c where Solitair_Game_Id__c = :gameId';
        SolitaireResultsBatch srb = new SolitaireResultsBatch(queueary, gameId, boardId);
        Id batchId = Database.executeBatch(srb);
    }

    public static void generateResultTable(List<Solitair_Metadata__c> boards, Id gameId, Id boardId) {

        
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
        
        insert results;
    }

    private static void calculateMinPath(List<Solitair_Result__c> results, String boardId) {
        Set<String> ids = new Set<String>();
        ids.add(boardId);
    
        List<Solitair_Result__c> boards = new List<Solitair_Result__c>(results);

        // System.debug('BoardId: ' + boardId);
        // SolitaireSolver.printList('Board list for min path calulation:', temp);
        Boolean found = false;
        do {
            found = false;
            Integer i;
            for (i = 0; i < boards.size(); i++) {
                Solitair_Result__c board = boards.get(i);
                found = ids.contains(board.board_Id__c);
                //|| ids.contains(board.parent_board_Id__c);
                if (found) {
                    //ids.add(board.board_Id__c);
                    ids.add(board.parent_board_Id__c);
                    board.min_path__c = true;
                    found = true;
                    boards.remove(i);
                    break;
                }
            }
        } while (found);
    }
}