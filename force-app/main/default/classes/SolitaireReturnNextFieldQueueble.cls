/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-15-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class SolitaireReturnNextFieldQueueble implements Queueable {

    private List<Solitair_Metadata__c> boardList;
    private Id boardId;
    private String cardAddress;
    private String cardValue;

    public SolitaireReturnNextFieldQueueble(List<Solitair_Metadata__c> boardList, Id boardId, String cardAddress, String cardValue) {
        this.boardList = boardList;
        this.boardId = boardId;
        this.cardAddress = cardAddress;
        this.cardValue = cardValue;
    }
    public void execute(QueueableContext context) {
        
        // System.debug('Start Queueable Execution:');
        // System.debug('boardId:' + boardId + '_cardAddress:' + cardAddress + '_cardValue:' + cardValue);

        SolitaireReturnNextField.startQuableBoardVarintsCalculation(this.boardList, this.boardId, this.cardAddress, this.cardValue);



    //     for(Solitair_Metadata__c boardDb : boardList) {

    //         Board board = (Board) JSON.deserialize(boardDb.Value__c, Board.class);

    //         //new set + new card
    //         SolitaireReturnNextField.defineLocationAndPutCard(board, cardAddress, cardValue);

    //         // board.level++;
    //         board.boardId = boardDb.id;
    //         board.key = SolitaireSolver.generateBoardVariantKey(board);
    //         boardDb.key__c = board.key;

    //         if (!SolitaireSolver.haveNoSuchVariant(board)) {
    //             //if db contains board with same key, delete ones with larger level
    //             List<Solitair_Metadata__c> boardListExist = [select id, value__c from Solitair_Metadata__c where Key__c = :board.key and Solitair_Game_Id__c = :board.gameId];
    //             for (Solitair_Metadata__c boardExistDb : boardListExist) {
    //                 Board boardExist = (Board) JSON.deserialize(boardExistDb.Value__c, Board.class);
    //                 boardExist.boardId = boardExistDb.id;
    //                 if (board.boardId != boardExistDb.id) {
    //                     if (boardExist.level > board.level) {
    //                             delete boardExistDb;
    //                     } else {
    //                         delete boardDb;
    //                         boardDb = boardExistDb;
    //                         if (board.boardId.equals(boardId)) {   
    //                             boardId = boardExistDb.id;
    //                         }
    //                         board = boardExist;
    //                     }
    //                 }
    //             }
    //         }
            
    //         boardDb.value__c = JSON.serialize(board);
    //         boardDb.completed__c = false;

    //         System.debug('Update completed field:');
    //         System.debug(boardDb);
    //         update boardDb;

    //         //calculate solutions
    //         List<Board> newBoards = new List<Board>();
    //         newBoards.add(board);

    //         while (newBoards.size() > 0) {
    //             System.debug('Calculate variant for boards:');
    //             System.debug(newBoards);
    //             Board boardNext = newBoards.remove(0);
    //             List<Board> boadsGenerated = SolitaireSolver.calculateVariants(boardNext);
    //             if (boadsGenerated.size() > 0) {
    //                 newBoards.addAll(boadsGenerated);
    //             }
    //         }
    //     }
    //     System.debug('End Queueable Execution:');
    //     System.debug('boardId:' + boardId + '_cardAddress:' + cardAddress + '_cardValue:' + cardValue);
    }
}