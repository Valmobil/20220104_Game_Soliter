/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-22-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global with sharing class SolitaireReturnNextField {

    public static final Integer FUNDAMENTAL_SIZE = 4;
    public static final Integer RUNNING_SIZE = 7;
    public static final Integer STOCK_PAIL_SIZE = 2;
    public static final Integer STOCK_PAIL_LENGTH = 4;
    
    @AuraEnabled
    public static String openOneCard(String boardId, String cardAddress, String cardValue) {

        //the method add opened card and generate new boards if possible
        List<Solitair_Metadata__c> boardList = [select id, Solitair_Game_Id__c, Value__c
            from Solitair_Metadata__c where id = :boardId];
        if (boardList.size() == 0) {
            return '';
        } else {
            Solitair_Metadata__c boardDb = boardList.get(0);
            Board board = (Board) JSON.deserialize(boardDb.Value__c, Board.class);

            //new set + new card
            defineLocationAndPutCard(board, cardAddress, cardValue);

            // board.level++;
            board.boardId = boardDb.id;
            board.key = SolitaireSolver.generateBoardVariantKey(board);
            boardDb.key__c = board.key;         
            String result = JSON.serialize(board);
            boardDb.value__c = result;

            update boardDb;

            //calculate solutions
            List<Board> newBoards = new List<Board>();
            newBoards.add(board);

            while (newBoards.size() > 0) {
                System.debug('Calculate variant for boards:');
                System.debug(newBoards);
                Board boardNext = newBoards.remove(0);
                List<Board> boadsGenerated = SolitaireSolver.calculateVariants(boardNext);
                if (boadsGenerated.size() > 0) {
                    newBoards.addAll(boadsGenerated);
                }
            }

            return result;
        }
    }

    @AuraEnabled
    public static String openSelectedBoard(String boardId) {

        //the method add opened card and generate new boards if possible
        System.debug('boardId: ' + boardId);
        if (boardId.contains('-')) {
            boardId = boardId.substring(0, boardId.indexOf('-'));
        }
        List<Solitair_Metadata__c> boardList = [select id, Solitair_Game_Id__c, Value__c
        from Solitair_Metadata__c where id = :boardId];
        if (boardList.size() == 0) {
            return '';
        } else {
            Solitair_Metadata__c boardDb = boardList.get(0);
            Board board = (Board) JSON.deserialize(boardDb.Value__c, Board.class);

            // board.level++;
            board.boardId = boardDb.id;
            String result = JSON.serialize(board);

            return result;
        }
    }

    private static void defineLocationAndPutCard(Board board, String address, String cardValue) {
        try {
            Address adrs = new Address(address);
            Card card = null; 
            if (adrs.firstLetter == 'r') {
                card = board.runningTrack.get(adrs.lineNumber).value.get(adrs.position);
            } else if (adrs.firstLetter == 'f') {
                card = board.fundamental.get(adrs.lineNumber).value.get(adrs.position);
            } else if (adrs.firstLetter == 's') {
                card = board.stockPail.get(adrs.lineNumber).value.get(adrs.position);
            }
            card.value = cardValue;
            card.isKnown = !String.isEmpty(cardValue);
        } catch (Exception e) {
            System.debug('Cell Address: ' + address);
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
        board.parentId = null;
        board.level = 0;
        board.runningTrack = generateInitialSet('r', RUNNING_SIZE, 7);
        board.fundamental = generateInitialSet('f', FUNDAMENTAL_SIZE, 1);
        board.stockPail = generateInitialSet('s', STOCK_PAIL_SIZE, STOCK_PAIL_LENGTH);
        board.fundamental = SolitaireSolver.normalizeFoundation(board.fundamental);
        board.key = SolitaireSolver.generateBoardVariantKey(board);
 
        String result = JSON.serialize(board);

        List<Solitair_Metadata__c> boardList = [select id, Solitair_Game_Id__c from Solitair_Metadata__c where Solitair_Game_Id__c = :board.boardId];
        if (boardList.size() == 0) {
            Solitair_Metadata__c boardDb = board.mapperBoardToBoardDb(board.gameId, 'Board', result, board.key);
            insert boardDb;
            board.boardId = boardDb.id;
        } else {
            board.gameId = boardList.get(0).Solitair_Game_Id__c;
            board.boardId = boardList.get(0).id;
        }
        result = JSON.serialize(board);
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
                    // remove after test
                    if (i == 1) {
                        card.value = '9D';
                    } else if (i == 2) {
                        card.value = 'JC';
                    } else if (i == 3) {
                        card.value = 'KD';
                    } else if (i == 4) {
                        card.value = '5C';
                    } else if (i == 5) {
                        card.value = 'AC';
                    } else if (i == 6) {
                        card.value = 'KP';
                    }
                    if (i < 7 && i > 0) {
                        card.isKnown = true;
                    }
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
}