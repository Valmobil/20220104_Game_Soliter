/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-14-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global with sharing class SolitaireReturnNextField {

    public static final Integer FUNDAMENTAL_SIZE = 4;
    public static final Integer RUNNING_SIZE = 7;
    public static final Integer STOCK_PAIL_SIZE = 2;
    public static final Integer STOCK_PAIL_LENGTH = 7;
    
    @AuraEnabled
    public static String openOneCard(Id gameId, Id boardId, String cardAddress, String cardValue) {

        System.debug('Open One Card - method:');
        System.debug('gameId:' + gameId + 'boardId:' + boardId + '_cardAddress:' + cardAddress + '_cardValue:' + cardValue);

        //the method add opened card and generate new boards if possible
        List<Solitair_Metadata__c> boardList = [select id, Solitair_Game_Id__c, Value__c
            from Solitair_Metadata__c where Solitair_Game_Id__c = :gameId and completed__c = false];
        
        //find one current board
        Integer index;
        String result;
        for (Integer i = 0; i < boardList.size(); i++) {
            Solitair_Metadata__c boardDb = boardList.get(i);
            if (boardId == boardDb.id) {
                List<Solitair_Metadata__c> tmpList = new List<Solitair_Metadata__c>();
                tmpList.add(boardDb);
                result = startQuableBoardVarintsCalculation(boardList, boardId, cardAddress, cardValue);
                index = i;
                break;
            }
        }

        boardList.remove(index);

        //run all other boards in queueable
        Integer perEach = 2;
        List<Solitair_Metadata__c> tmpList;
        for (Integer i = 0; i < boardList.size(); i++) {
            // if (Math.Mod(i, perEach) == 0)  {
                tmpList = new List<Solitair_Metadata__c>();
            // }
            tmpList.add(boardList.get(i));
            // if (Math.Mod(i, perEach) == perEach - 1 || i == boardList.size() - 1) {
                Id jobID = System.enqueueJob(new SolitaireReturnNextFieldQueueble(tmpList, boardId, cardAddress, cardValue));
            // }    
        }
        
        // SolitaireSolver.printList('List of boards for update:', boardList);
        // AsyncApexJob jobInfo = [SELECT Status,NumberOfErrors FROM AsyncApexJob WHERE Id=:jobID];
        // System.debug('AsyncApexJobStatus:' + jobInfo);

        return result;

    }

    public static String startQuableBoardVarintsCalculation(List<Solitair_Metadata__c> boardList, Id boardId, String cardAddress, String cardValue) {
        
        String result = '';
        
        for(Solitair_Metadata__c boardDb : boardList) {

            Board board = (Board) JSON.deserialize(boardDb.Value__c, Board.class);

            //new set + new card
            defineLocationAndPutCard(board, cardAddress, cardValue);

            // board.level++;
            board.boardId = boardDb.id;
            board.key = SolitaireSolver.generateBoardVariantKey(board);
            boardDb.key__c = board.key;

            if (!SolitaireSolver.haveNoSuchVariant(board)) {
                //if db contains board with same key, delete ones with larger level
                List<Solitair_Metadata__c> boardListExist = [select id, value__c from Solitair_Metadata__c where Key__c = :board.key and Solitair_Game_Id__c = :board.gameId];
                for (Solitair_Metadata__c boardExistDb : boardListExist) {
                    Board boardExist = (Board) JSON.deserialize(boardExistDb.Value__c, Board.class);
                    boardExist.boardId = boardExistDb.id;
                    if (board.boardId != boardExistDb.id) {
                        if (boardExist.level > board.level) {
                            delete boardExistDb;
                        } else {
                            try {
                                delete boardDb;    
                            } catch (Exception e) {
                                System.debug('Cannot delete board:');
                                System.debug(board.level + ' ' + board.key + ' ' + board.boardId);
                                System.debug(boardExist.level + ' ' + boardExist.key + ' ' + boardExist.boardId);
                            }                            
                            return JSON.serialize(boardExist); 
                        }
                    }
                }
            }
            
            if (boardDb.Id.equals(boardId)) {    
                //refresh result ony for called boardId     
                result = JSON.serialize(board);
            }
            boardDb.value__c = JSON.serialize(board);
            boardDb.completed__c = false;

            System.debug('Update completed field:');
            System.debug(boardDb);
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
        }

        return result;
    }

    @AuraEnabled
    public static String openSelectedBoard(String boardId) {

        //the method add opened card and generate new boards if possible
        System.debug('boardId: ' + boardId);

        List<Solitair_Metadata__c> boardList = [select id, Solitair_Game_Id__c, Value__c
        from Solitair_Metadata__c where id = :boardId];
        if (boardList.size() == 0) {
            return '';
        } else {
            Solitair_Metadata__c boardDb = boardList.get(0);
            System.debug('Board db:');
            System.debug(boardDb);

            Board board = (Board) JSON.deserialize(boardDb.Value__c, Board.class);

            System.debug('Board:');
            System.debug(board);
            // board.level++;
            board.boardId = boardDb.id;
            board.gameId = boardDb.Solitair_Game_Id__c;
            String result = JSON.serialize(board);

            System.debug('Board result:');
            System.debug(result);
            return result;
        }
    }

    public static void defineLocationAndPutCard(Board board, String address, String cardValue) {
        if (!setCardValue(board.stockPail, address, cardValue)) {
            if (!setCardValue(board.fundamental, address, cardValue)) {
                setCardValue(board.runningTrack, address, cardValue);
            }    
        }
    }

    private static Boolean setCardValue(List<Line> inputLine, String address, String CardValue) {
        for (Line line : inputLine) {
            for (Card card : line.value) {
                if (card.addressOriginal == address) {
                    card.value = cardValue;
                    card.isKnown = true;  
                    return true;          
                }
            }
        }
        return false;
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
            SolitaireSolver.boardListSet.add(board.key);
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