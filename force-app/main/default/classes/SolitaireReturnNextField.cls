/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-19-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class SolitaireReturnNextField {


    public static final Integer FUNDAMENTAL_SIZE = 4;
    public static final Integer RUNNING_SIZE = 7;
    
    @AuraEnabled
    public static String openOneCard(String boardId, String cardAddress, String cardValue) {
        //the method add opened card and create new board with it

        System.debug('Open One Card');
        System.debug(boardId);
        System.debug(cardAddress);
        System.debug(cardValue);
        List<Solitair_Metadata__c> boardList = [select id, Solitair_Game_Id__c, Value__c 
            from Solitair_Metadata__c where id = :boardId];
        if (boardList.size() == 0) {
            return '';
        } else {
            Solitair_Metadata__c boardDb = boardList.get(0);
            System.debug('boardDb.value__c: ');
            System.debug(boardDb.value__c);
            Board board = (Board) JSON.deserialize(boardDb.Value__c, Board.class);
            
            System.debug('oldBoard:');
            System.debug(board);
            
            board.boardId = null;
            System.debug(board);
  

            //new set + new card
            defineLocationAndPutCard(board, cardAddress, cardValue);
            
            System.debug('newBoard(1):');
            System.debug(board);
            System.debug(board.runnignTrack);
            System.debug(board.level);
            System.debug(board.boardId);
            

            board.level++;
            String result = JSON.serialize(board);
            Solitair_Metadata__c boardDbNew = mapperBoardToBoardDb(board.gameId, 'Board', result);

            insert(boardDbNew);

            board.boardId = boardDbNew.id;
            System.debug('newBoard(2):');
            System.debug(boardDbNew);
            System.debug(board.runnignTrack);
            System.debug(board.level);
            System.debug(board.boardId);
            result = JSON.serialize(board);

            return result;
        }
    }

    private static void defineLocationAndPutCard(Board board, String addr, String cardValue) {
        try {
            String firstLetter = addr.substring(0,1);
            Integer lineNumber = Integer.valueOf(addr.substring(2,3));
            Integer position = Integer.valueOf(addr.substring(4,5));
            Card card = null; 
            if (firstLetter == 'r') {
                card = board.runnignTrack.get(lineNumber).value.get(position);
            } else if (firstLetter == 'f') {
                card = board.fundamental.get(lineNumber).value.get(position);
            } else if (firstLetter == 's') {
                card = board.stockPail.get(lineNumber).value.get(position);
            }
            card.value = cardValue;
            card.isEmpty = String.isEmpty(cardValue);
        } catch (Exception e) {
            System.debug('Cell Address: ' + addr);
            System.debug(addr.substring(0,1));
            System.debug(addr.substring(2,3));
            System.debug(addr.substring(4,5));  
        }
    }


    @AuraEnabled
    public static String getInitialBoard() {
        
        System.debug('APEX: getInitialBoard');
        // List<Solitair_Game__c> games = [select name from Solitair_Game__c];
        // Solitair_Game__c game;
        // if (games.size() == 0) {
        Solitair_Game__c game = new Solitair_Game__c();
        game.name = 'Game_Name_' + System.now();
        // games.add(game);
        System.debug('New game: ' + game.id);
        insert game;
        // } else {
        //     game = games.get(0);
        // }
        System.debug('New game: ' + game.id);
        Board board = new Board();
         
        board.gameId = game.id;
        board.parentId = 0;
        board.level = 0;
        board.fundamental = new List<Line>();
        for (Integer i = 0; i < FUNDAMENTAL_SIZE; i++) {
            System.debug(board.fundamental);
            //Add fundamental lines
            board.fundamental.add(new Line(i));

            //add card to line
            Card card = new Card('f_' + i + '_0', '');
            board.fundamental.get(i).value.add(card);

            //add second card to line - for test purposes
            card = new Card('f_' + i + '_1', '');
            board.fundamental.get(i).value.add(card);
        }
        board.runnignTrack = new List<Line>();
        for (Integer i = 0; i < RUNNING_SIZE; i++) {
            board.runnignTrack.add(new Line(i));

            //add card to line
            Card card = new Card('r_' + i + '_0', '');
            board.runnignTrack.get(i).value.add(card);
        }
        board.stockPail = new List<Line>();
        board.stockPail.add(new Line(0));
        board.stockPail.get(0).value.add(new Card('s_0_0', ''));
 
        String result = JSON.serialize(board);

        List<Solitair_Metadata__c> boardList = [select id, Solitair_Game_Id__c from Solitair_Metadata__c where Solitair_Game_Id__c = :board.boardId];
        if (boardList.size() == 0) {
            System.debug('No boards');
            Solitair_Metadata__c boardDb = mapperBoardToBoardDb(board.gameId, 'Board', result);
            insert boardDb;
            board.boardId = boardDb.id;
        } else {
            board.gameId = boardList.get(0).Solitair_Game_Id__c;
            board.boardId = boardList.get(0).id;
            // дописать восстановление из базы
        }
        result = JSON.serialize(board);
        System.debug('Result to LWC: ' + result);
        return result;
    }


    private static Solitair_Metadata__c mapperBoardToBoardDb(Id gameId, String boardType, String jsonString) {
        Solitair_Metadata__c boardDb = new Solitair_Metadata__c();
        boardDb.Solitair_Game_Id__c = gameId;
        boardDb.Type__c = 'Board';
        boardDb.Value__c = jsonString;
        return boardDb;
    }

    class Board {
        Id boardId;
        Integer parentId;
        Id gameid;
        Integer level;
        List<Line> fundamental;
        List<Line> stockPail;
        List<Line> runnignTrack;
    }

    class Card {

        Card(String address, String value) {
            this.address = address;
            if (String.isEmpty(value)) {
                this.value = '';
                this.isEmpty = true; 
            } else {
                this.value = value;
            }
        }

        public void setAddress(String address) {
            address = address;
        }

        String address;
        String value;
        Boolean isEmpty = false;
    }

    class Line {
        Line(Integer i) {
            this.id = i;
            this.value = new List<Card>();
        }
        Integer id;
        List<Card> value;
    }

}
