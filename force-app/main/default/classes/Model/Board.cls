/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-24-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global with sharing class Board {
    public Board() {
    }

    public Board cloneBoard() {
        String jsonStr = JSON.serialize(this);
        Board newBoard = (Board) JSON.deserialize(jsonStr, Board.class);
        newBoard.boardId = null;
        newBoard.gameId = this.gameId;
        newBoard.parentId = this.boardId;
        newBoard.level = this.level + 1;
        return newBoard;
    }

    global Solitair_Metadata__c mapperBoardToBoardDb(Id gameId, String boardType, String jsonString) {
        Solitair_Metadata__c boardDb = new Solitair_Metadata__c();
        boardDb.Solitair_Game_Id__c = gameId;
        boardDb.Type__c = boardType;
        boardDb.Value__c = jsonString;
        return boardDb;
    }

    global Id boardId;
    global Id parentId;
    global Id gameId;
    global Integer level;
    global String lastMove;
    global List<Line> fundamental;
    global List<Line> stockPail;
    global List<Line> runningTrack;
}