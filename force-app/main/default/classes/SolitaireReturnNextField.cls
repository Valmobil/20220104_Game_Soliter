/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-21-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global with sharing class SolitaireReturnNextField {


    public static final Integer FUNDAMENTAL_SIZE = 4;
    public static final Integer RUNNING_SIZE = 7;
    public static final Integer STOCK_PAIL_SIZE = 2;
    public static final Integer STOCK_PAIL_LENGTH = 1;

    
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
            
            // board.boardId = null;
            // System.debug(board);

            //new set + new card
            defineLocationAndPutCard(board, cardAddress, cardValue);

            // board.level++;
            board.boardId = boardDb.id;
            String result = JSON.serialize(board);
            boardDb.value__c = result;
        
            //Solitair_Metadata__c boardDbNew = mapperBoardToBoardDb(board.gameId, 'Board', result);

            update boardDb;

            // board.boardId = boardDbNew.id;

            //calculate solutions
            // SolitaireSolver.calculateVariarnts(board);

            //result = JSON.serialize(board);

            return result;
        }
    }

 
    private static void defineLocationAndPutCard(Board board, String addr, String cardValue) {
        try {
            Integer firstIndex = addr.indexOf('_');
            Integer secondIndex = addr.indexOf('_', firstIndex + 1);
            String firstLetter = addr.substring(0,firstIndex);
            Integer lineNumber = Integer.valueOf(addr.substring(firstIndex + 1,secondIndex));
            Integer position = Integer.valueOf(addr.substring(secondIndex + 1, addr.length()));
            Card card = null; 
            if (firstLetter == 'r') {
                card = board.runnignTrack.get(lineNumber).value.get(position);
            } else if (firstLetter == 'f') {
                card = board.fundamental.get(lineNumber).value.get(position);
            } else if (firstLetter == 's') {
                card = board.stockPail.get(lineNumber).value.get(position);
            }
            card.value = cardValue;
            card.isKnown = !String.isEmpty(cardValue);
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
        Solitair_Game__c game = new Solitair_Game__c();
        game.name = 'Game_Name_' + System.now();
        insert game;
        System.debug('New game: ' + game.id);
        Board board = new Board();
        board.gameId = game.id;
        board.parentId = 0;
        board.level = 0;
        board.runnignTrack = generateInitialSet('r', RUNNING_SIZE, 7);
        board.fundamental = generateInitialSet('f', FUNDAMENTAL_SIZE, 1);
        board.stockPail = generateInitialSet('s', STOCK_PAIL_SIZE, STOCK_PAIL_LENGTH);
 
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
        }
        result = JSON.serialize(board);
        System.debug('Result to LWC: ' + result);
        return result;
    }

    private static List<Line> generateInitialSet(String type, Integer size, Integer length) {
        List<Line> lines = new List<Line>();
        for (Integer i = 0; i < size; i++) {

            //Add lines
            lines.add(new Line(i));

            Integer customLength = (type == 'r' ? i + 1 : ((type == 's' && i == 0) ? 1 : length));

        
            for (Integer j = 0; j < customLength; j++) {
                //add card to line
                Card card = new Card(type + '_' + i + '_' + j, '');
                
                //open each last card for running pails
                if (type == 'r' && j == i) {
                    card.isOpen = true;
                } 
                if (type == 'f') {
                    card.isEmpty = true;
                }
                if (type == 's' && i == 0) {
                    card.isEmpty = true;
                }
                lines.get(i).value.add(card);
            }
        }
        if (type == 's') {
            System.debug('Type: s' + ' Lines:' + lines);
        }

        return lines;
    }

    private static Solitair_Metadata__c mapperBoardToBoardDb(Id gameId, String boardType, String jsonString) {
        Solitair_Metadata__c boardDb = new Solitair_Metadata__c();
        boardDb.Solitair_Game_Id__c = gameId;
        boardDb.Type__c = 'Board';
        boardDb.Value__c = jsonString;
        return boardDb;
    }

    global class Board {
        Id boardId;
        Integer parentId;
        Id gameid;
        Integer level;
        List<Line> fundamental;
        List<Line> stockPail;
        global List<Line> runnignTrack;
    }

    global class Card {
        Card(String address, String value) {
            this.address = address;
            if (String.isEmpty(value)) {
                this.value = '';
                this.isKnown = false; 
            } else {
                this.value = value;
                this.isKnown = true; 
            }
        }

        public void setAddress(String address) {
            address = address;
        }

        global String address;
        global String value;
        global Boolean isEmpty = false;
        global Boolean isOpen = false;
        global Boolean isKnown = false;
    }

    global class Line {
        Line(Integer i) {
            this.id = i;
            this.value = new List<Card>();
        }
        Integer id;
        global List<Card> value;
    }

}
