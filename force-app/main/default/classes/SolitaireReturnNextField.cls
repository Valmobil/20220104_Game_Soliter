/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-17-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class SolitaireReturnNextField {


    public static final Integer FUNDAMENTAL_SIZE = 4;
    public static final Integer RUNNING_SIZE = 7;
    public static Integer uniqueIndex = 0;
    
    @AuraEnabled
    public static String openOneCard(String boardId, String cardId, String cardValue) {
        System.debug('Open One Card');
        System.debug(boardId);
        System.debug(cardId);
        System.debug(cardValue);
        return '';
    }

    @AuraEnabled
    public static String getInitialBoard() {
        List<Solitair_Game__c> games = [select name from Solitair_Game__c];
        Solitair_Game__c game;
        if (games.size() == 0) {
            game = new Solitair_Game__c();
            game.name = 'Game_Name_' + System.now();
            games.add(game);
            insert games;
        } else {
            game = games.get(0);
        }

        Board board = new Board();
         
        board.gameId = game.id;
        board.parentId = 0;
        board.fundamental = new List<Line>();
        for (Integer i = 0; i < FUNDAMENTAL_SIZE; i++) {
            System.debug(board.fundamental);
            //Add fundamental lines
            Line line = new Line(i);
            board.fundamental.add(line);

            //add card to line
            Card card = new Card();
            card.id = uniqueIndex;
            uniqueIndex++;
            card.address = 'f_' + i + '_0';
            card.value = '';
            card.isEmpty = true;
            board.fundamental.get(i).value.add(card);

            //add second card to line - for test purposes
            card = new Card();
            card.id = uniqueIndex;
            uniqueIndex++;
            card.address = 'f_' + i + '_1';
            card.value = '';
            card.isEmpty = true;
            board.fundamental.get(i).value.add(card);
        }
        board.runnignTrack = new List<List<String>>();
        for (Integer i = 0; i < RUNNING_SIZE; i++) {
            board.runnignTrack.add(new String[] {''});
        }
        board.stockPail = new List<String>();
        board.stockPail.add('');
        String result = JSON.serialize(board);

        List<Solitair_Metadata__c> boardList = [select id, Solitair_Game_Id__c from Solitair_Metadata__c];
        if (boardList.size() == 0) {
            System.debug('No boards');
            Solitair_Metadata__c boardDb = new Solitair_Metadata__c();
            boardDb.Solitair_Game_Id__c = board.gameId;
            boardDb.Type__c = 'Board';
            boardDb.Value__c = result;
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

    class Board {
        Id boardId;
        Integer parentId;
        Id gameid;
        List<Line> fundamental;
        String[] stockPail;
        String[][] runnignTrack;
    }

    class Card {
        // public Card(String value) {
        //     id = uniqueIndex;
        //     uniqueIndex++;
        //     if value.isEmpty(
        //         this.value = '';
        //         this.isEmpty = true; 
        //     ) else {
        //         this.value = value;
        //     }
        // }
        // setAddress(String address) {
        //     address = address;
        // }
        Integer id;
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
