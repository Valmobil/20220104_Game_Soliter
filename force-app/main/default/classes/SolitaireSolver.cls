/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-19-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class SolitaireSolver {

    public static Map<String, String[]> possiblePlaces = new Map<String, String[]>();
    public static Set<String> boardListSet = new Set<String>();

    static {
        // System.debug('Start Initiate Available Moves');
        initAvailableMoves();
    }

    public static List<Board> calculateVariants(Board board) {

        //set map of existing cards running tracks
        Map<String, String> knownCards = collectExistingCardsList(board);
        //printList('Known cards:', knownCards);
        if (knownCards == null) {
            return new List<Board>();
        }

        //If all variants already calculated put respective mark Completed = true;
        Solitair_Metadata__c boardDb = new Solitair_Metadata__c();
        boardDb.id = board.boardId;
        boardDb.completed__c = true;
        update boardDb;

        //take one card and check for possible movements
        List<PossibleMovement> possibleMovements = preparePossibleMovements(board, knownCards);
        //printList('Possible movements:', possibleMovements);

        List<Board> boardsNew = new List<Board>();
        List<Solitair_Metadata__c> boardsNewDb = new List<Solitair_Metadata__c>();

        //generate new board for each movement
        Boolean enableMoveFromFoundation = true;
        for (PossibleMovement oneMove : possibleMovements) {

            Address adrCardFrom = new Address(oneMove.cardFromAddress);
            Address adrCardTo = new Address(oneMove.cardToAddress);
            
            if (adrCardFrom.firstLetter != 'f' || enableMoveFromFoundation) {
                Board newBoard = board.cloneBoard();
                newBoard.lastMove = board.level + '.' + oneMove.cardFromValue + '(' + adrCardFrom.toString() + ')->' + oneMove.cardToValue + '(' + adrCardTo.toString() + ')';
                
                //checkCardAddress(newBoard);
                if(moveCards(newBoard, adrCardFrom, adrCardTo, oneMove)) {
                    newBoard.fundamental = normalizeFoundation(newBoard.fundamental);
                    newBoard.key = generateBoardVariantKey(newBoard);
                    //checkCardAddress(newBoard);
    
                    if (haveNoSuchVariant(newBoard)) {
                        enableMoveFromFoundation = false;
                        String result = JSON.serialize(newBoard);
                        Solitair_Metadata__c boardDbNew = board.mapperBoardToBoardDb(board.gameId, 'Board', result, newBoard.key);
                        boardsNewDb.add(boardDbNew);
                        boardListSet.add(newBoard.key);

                        //run variant calculation
                        newBoard.boardId = boardDbNew.id;
                        boardsNew.add(newBoard);
                    }
                }
            }
        }

        insert boardsNewDb;
        for (Integer i = 0; i < boardsNewDb.size(); i++) {
            boardsNew.get(i).boardId = boardsNewDb.get(i).id;
        }

        return boardsNew;
    }

    private static void checkCardAddress(Board board) {
        checkCardAddressOfOneType(board, board.fundamental, 'fundamentls', 'f');
        checkCardAddressOfOneType(board, board.runningTrack, 'runningTrack','r');
    }

    private static void checkCardAddressOfOneType(Board board, List<Line> lines, String typeName, String type) {
        for (Integer i = 0; i < lines.size(); i++) {
            Line line = lines.get(i);
            for (Integer j = 0; j < line.value.size(); j++) {
                Card card = line.value.get(j);

                Address address = new Address(card.address);
                if (address.firstLetter != type) {
                    // System.debug('Error in ' + typeName + ' address first letter - should be "' + type + '": ' + card.address);
                    // System.debug('Board ' + typeName + ' line: ' + line);
                    // System.debug('Board id:' + board.boardId);
                    // System.debug('Board last move' + board.lastMove);
                    // System.debug('Board level: ' + board.level);
                    
                    CalloutException e = new CalloutException();
                    e.setMessage('Error in ' + typeName + ' address - first letter');
                    throw e;
                }
                
                if (address.lineNumber != i) {
                    // System.debug('Error in ' + typeName + ' address line number - should be: ' + i + ' _ ' + card.address);
                    // System.debug('Board ' + typeName + ' line: ' + line);
                    // System.debug('Board id:' + board.boardId);
                    // System.debug('Board last move' + board.lastMove);
                    // System.debug('Board level: ' + board.level);

                    CalloutException e = new CalloutException();
                    e.setMessage('Error in ' + typeName + ' address - line number');
                    throw e;
                }

                if (address.position != j) {
                    // System.debug('Error in ' + typeName + ' address position - should be: ' + j + ' _ ' + card.address);
                    // System.debug('Board ' + typeName + ' line: ' + line);
                    // System.debug('Board id:' + board.boardId);
                    // System.debug('Board last move' + board.lastMove);
                    // System.debug('Board level: ' + board.level);
                    
                    CalloutException e = new CalloutException();
                    e.setMessage('Error in ' + typeName + ' address - position');
                    throw e;
                }
            }
        }
    }

    public static String generateBoardVariantKey(Board board) {
        String key = '';
        key+= 'Run:';
        key+= addCardValue(board.runningTrack);
        
        key+= '_Sto:';
        key+= addCardValue(board.stockPail);

        key+= 'Fun:';
        key+= addCardValue(board.fundamental);

        return key;
    }

    private static String addCardValue(List<Line> pail) {
        String str = '';
        for (Line line : pail) {
            str+= '_';
            for (Card card : line.value) {
                if(card.isKnown && card.isOpen) {
                    str+= card.value;
                } else {
                    if (card.isOpen) {
                        str+= 'NA';
                    }
                }
            }
        }
        return str;
    }

    public static Boolean haveNoSuchVariant(Board board) {

        if (boardListSet.size() == 0) {
            List<Solitair_Metadata__c> boardList = [select id, key__c from Solitair_Metadata__c where Solitair_Game_Id__c = :board.gameId];
            for (Solitair_Metadata__c boardTmp : boardList) {
                boardListSet.add(boardTmp.key__c);
            }             
        }

        if (!boardListSet.contains(board.key)) {            
            // System.debug('have no board');
            return true;
        } else {
            // System.debug('board exists');
            return false;
        }
    }

    private static List<PossibleMovement> preparePossibleMovements(Board board, Map<String, String> knownCards) {
        List<PossibleMovement> possibleMovements = new List<PossibleMovement>();

        //running track possible movements
        for (Line line : board.runningTrack) {
            for (Card card : line.value) {
                if (card.isOpen) {
                    findPossibleMovements(possibleMovements, card, knownCards);
                }
            }
        }

        //fundamental possible movements
        //move only last card in a line
        for (Line line : board.fundamental) {
            Card card = line.value.get(line.value.size()-1);
            findPossibleMovements(possibleMovements, card, knownCards);
        }

        //stock pale possible movements
        //move already open stock pale last card (left line)
        if(board.stockPail.size() > 0) {
            Line line = board.stockPail.get(0);
            if(line.value.size() > 0) {
                Card card = line.value.get(line.value.size()-1);
                findPossibleMovements(possibleMovements, card, knownCards);
            }
        }
        //printList('Possible movements (draft):', possibleMovements);


        //stock pale possible movements
        //move one card from right line
        if(board.stockPail.size() > 1) {
            Line line = board.stockPail.get(1);
            Line lineTo = board.stockPail.get(0);
            if(line.value.size() > 0) {
                Card card = line.value.get(line.value.size() - 1);
                if (!card.isEmpty) {
                    Card cardTo = lineTo.value.get(lineTo.value.size() - 1);
                    if (cardTo.isKnown || cardTo.isEmpty) {
                        PossibleMovement pm = new PossibleMovement(card.value, card.address, cardTo.value, cardTo.address);
                        possibleMovements.add(pm);    
                    }
                } else {
                    card = lineTo.value.get(1);
                    Card cardTo = line.value.get(0);
                    
                    PossibleMovement pm = new PossibleMovement(card.value, card.address, cardTo.value, cardTo.address);
                    possibleMovements.add(pm);  
                }
            }
        }

        // printList('Possible movements list:', possibleMovements);
        return possibleMovements;
    }

    public static void printList(String name, Map<String, String> myMap) {
        if (myMap != null) {
            List<String> myList = new List<String>();
            for (String key : myMap.keySet()) {
                myList.add(myMap.get(key) + '_ _' + key);
            }
            //printList(name, myList);
        // } else {
        //     printList(name, (List<String>) null);
        }
    }

    public static void printList(String name, Set<String> myMap) {
        if (myMap != null) {
            List<String> myList = new List<String>(myMap);
            //printList(name, myList);
        }
    }

    public static void printList(String name, List<Object> lst) {
        System.debug(name);
        if (lst == null) {
            System.debug('List == Null');
            return;
        }
        if (lst.size() == 0) {
            System.debug('List is empty: Size() == 0');
            return;
        }
        for (Object obj : lst) {
            System.debug(obj);
        }
    }


    private static void findPossibleMovements(List<PossibleMovement> possibleMovements, Card card, Map<String, String> knownCards) {
        List<String> nearCards = getNearCards(card.value);
        // System.debug('Card value' + card.value);
        //printList('Near card', nearCards);
        for (String nearCard : nearCards) {
            if (knownCards.containsKey(nearCard)) {
             
                String address = knownCards.get(nearCard);
                Address addrTo = new Address(address);

                if (addrTo.firstLetter == 'F') {
                    if ('F' != nearCard.substring(0,1) && card.value.charAt(card.value.length() - 1) != nearCard.charAt(nearCard.length() - 1)) {
                        //if Fundamental card has no same type
                        continue;
                    }
                }
                PossibleMovement pm = new PossibleMovement(card.value, card.address, nearCard, address);
                possibleMovements.add(pm);
            }
        }

    }


    private static Map<String, String> collectExistingCardsList(Board board) {
        Map<String, String> knownCards = new Map<String, String>();

        //collect available cards in running track
        for (Integer i = 0; i < board.runningTrack.size(); i++) {
            Line line = board.runningTrack.get(i);
            for (Card card : line.value) {
                if (card.isKnown == false && card.isOpen) {
                    //if we have at least one open but unknown card, stop analysis
                    return null;
                }
                String cardName = card.value;
                if (String.isBlank(cardName) && card.isEmpty) {
                    //if cell is blank fill with virtual card name
                    cardName = 'R' + i;
                }
                if ((card.isKnown && card.isOpen) || card.isEmpty ) {
                    //add only known cards and blank cells
                    knownCards.put(card.value, card.address);
                }
            }
        }

        //set map of existing cards in fundamentals
        for (Integer i = 0; i < board.fundamental.size(); i++) {
            Line line = board.fundamental.get(i);
            for (Integer j = 0; j < line.value.size(); j++) {
                if (j == line.value.size() - 1) {
                    Card card = line.value.get(j);
                    String cardName = card.value;
                    if (String.isBlank(cardName)) {
                        //if cell is blank fill with virtual card name
                        cardName = 'F' + i;
                    }
                    knownCards.put(cardName, card.address);
                }
            }
        }

        //collect available cards in stock pail
        //take only one last card from zero line
        Line line = board.stockPail.get(0);
        if (line.value.size() > 0) {
            Card card = line.value.get(line.value.size()-1);
            String cardName = card.value;
            if (card.isKnown == false && card.isOpen) {
                //if we have at least one open but unknown card, stop analysis
                return null;
            }
            if (card.isKnown && card.isOpen) {
                //add only known cards and blank cells
                knownCards.put(card.value, card.address);
            }
        } else {
            return null;
        }

        return knownCards;
    }

    private static void changeLineAddresses(Line line, Integer lineNum) {
        for (Card card : line.value) {
            Address addressNew = new Address(card.address);
            addressNew.lineNumber = lineNum;
            card.address = addressNew.toString();
        }
        line.id = lineNum;
    }

    private static Boolean moveCards(Board board, Address adrFrom, Address adrTo, PossibleMovement oneMove) {
        // System.debug('Move Cards from: ' + adrFrom.toString() + ' to: ' + adrTo.toString());
        
        // move fundamentals
        if (adrFrom.firstLetter == 'f') {
            List<Card> lineFrom = board.fundamental.get(adrFrom.lineNumber).value;
            if (lineFrom.size() != adrFrom.position + 1) {
                //we can move only the last card in line
                return false;
            } 
            if (adrTo.firstLetter == 'f') {
                //we cannot move cards between fundamentals
                return false;
            }
            if (adrTo.firstLetter == 's') {
                //we cannot move cards to stock pail
                return false;
            }
            List<Card> lineTo = board.runningTrack.get(adrTo.lineNumber).value;
            if (adrTo.firstLetter == 'r') {
                //we can move only on the latest running cards
                if (lineTo.size() != adrTo.position + 1) {
                    //we can move only the last card in line
                    return false;
                }
                if (!String.isBlank(oneMove.cardFromValue) && !String.isBlank(oneMove.cardToValue) 
                && oneMove.cardFromValue.right(1) == oneMove.cardToValue.right(1)) {
                    // if last cards' values coinsist - this variant only fro fundamentals
                    return false;
                }

            }
            // Move cards
            moveCardList(adrFrom, adrTo, lineFrom, lineTo);
            return true;
        }
        
        // move running pails
        if (adrFrom.firstLetter == 'r') {
            List<Card> lineFrom = board.runningTrack.get(adrFrom.lineNumber).value;
            List<Card> lineTo;
            if (adrTo.firstLetter == 's') {
                //we cannot move cards to stock pail
                return false;
            }
            if (adrTo.firstLetter == 'f') {
                lineTo = board.fundamental.get(adrTo.lineNumber).value;
                //we can move only on the latest running cards
                if (lineTo.size() != adrTo.position + 1) {
                    //we can move only the last card in line
                    return false;
                } 
            }
            if (adrTo.firstLetter == 'r') {
                lineTo = board.runningTrack.get(adrTo.lineNumber).value;
                //we can move only on the latest running cards
                if (lineTo.size() != adrTo.position + 1) {
                    //we can move only the last card in line
                    return false;
                } 
                if (!String.isBlank(oneMove.cardFromValue) && !String.isBlank(oneMove.cardToValue) 
                    && oneMove.cardFromValue.right(1) == oneMove.cardToValue.right(1)) {
                    // if last cards' values coinsist - this variant only fro fundamentals
                    return false;
                }
            }
            // Move cards
            removeBlankCardFromLine(lineTo, adrTo);
            moveCardList(adrFrom, adrTo, lineFrom, lineTo);

            //change address (addressOriginal w/o changes)
            //Card card = lineFrom.get(adrFrom.position);
            //Address addressNew = new Address(adrTo);
            //addressNew.position = lineTo.size();
            //card.address = addressNew.toString();

            //lineTo.add(card);
            //lineFrom.remove(adrFrom.position);

            //"open" last but one card
            if (adrFrom.position > 0) {
                lineFrom.get(adrFrom.position - 1).isOpen = true;
            }

            //add "empty" card on in blank line
            if (lineFrom.isEmpty()) {
                Card emptyCard = new Card();
                emptyCard.value = '';
                emptyCard.isEmpty = true;
                emptyCard.address = adrFrom.firstLetter + '_' + adrFrom.lineNumber + '_' + adrFrom.position;
                lineFrom.add(emptyCard);
            }
            return true;
        }

        // move stock pail
        if (adrFrom.firstLetter == 's') {
            // System.debug('Move from Stock Pail = ');
            List<Card> lineFrom = board.stockPail.get(adrFrom.lineNumber).value;
            List<Card> lineTo;
            if (adrTo.firstLetter == 's') {
                lineTo = board.stockPail.get(adrTo.lineNumber).value;
            }
            if (adrTo.firstLetter == 'f') {
                lineTo = board.fundamental.get(adrTo.lineNumber).value;
                //we can move only on the latest running cards
                if (lineTo.size() != adrTo.position + 1) {
                    //we can move only the last card in line
                    return false;
                } 
            }
            if (adrTo.firstLetter == 'r') {
                lineTo = board.runningTrack.get(adrTo.lineNumber).value;
                //we can move only on the latest running cards
                if (lineTo.size() != adrTo.position + 1) {
                    //we can move only the last card in line
                    return false;
                }
                if (!String.isBlank(oneMove.cardFromValue) && !String.isBlank(oneMove.cardToValue) 
                && oneMove.cardFromValue.right(1) == oneMove.cardToValue.right(1)) {
                    // if last cards' values coinsist - this variant only fro fundamentals
                    return false;
                } 
            }

            // Move cards
            // System.debug('Move ST');
            removeBlankCardFromLine(lineTo, adrTo);
            moveCardList(adrFrom, adrTo, lineFrom, lineTo);

            //"open" last stock pail card in first line
            if (lineTo.size() > 0) {
                lineTo.get(lineTo.size() - 1).isOpen = true;
            }

            //add "empty" card on in blank line
            if (lineFrom.isEmpty()) {
                Card emptyCard = new Card();
                emptyCard.value = '';
                emptyCard.isEmpty = true;
                emptyCard.address = adrFrom.firstLetter + '_' + adrFrom.lineNumber + '_' + adrFrom.position;
                lineFrom.add(emptyCard);
            }
            return true;
        }
        return false;
    }

    private static void moveCardList(Address adrFrom, Address adrTo, List<Card> lineFrom, List<Card> lineTo) {

        for (Integer i = adrFrom.position; i < lineFrom.size(); i++) {
            Card card = lineFrom.get(i);

            //change address (addressOriginal w/o changes)
            Address addressNew = new Address(adrTo);
            addressNew.position = lineTo.size();
            card.address = addressNew.toString(); 
            //add card

            lineTo.add(card);

        }

        Integer size = lineFrom.size();
        for (Integer i = adrFrom.position; i < size; i++) {
            lineFrom.remove(adrFrom.position);
        }

    }

    public static List<Line> normalizeFoundation(List<Line> fundamentals) {
        List<String> idealList = new List<String> {'P','C','D','H'};
        List<Line> sortedList = new List<Line>();
        //move not blank list

        //printList('Fundamentals: ', fundamentals);

        for (Integer i = 0; i < idealList.size(); i++) {
            for (Integer j = 0; j < fundamentals.size(); j++) {
                String value = fundamentals.get(j).value.get(0).value;
                if (!String.isBlank(value) && value.substring(1,2) == idealList.get(i)) {
                    sortedList.add(fundamentals.get(j));
                
                    //change line of address
                    changeLineAddresses(fundamentals.get(j), sortedList.size() - 1);
                }
            }
        }
        //move blank lists
        for (Integer i = 0; i < fundamentals.size(); i++) {
            String value = fundamentals.get(i).value.get(0).value;
            if (String.isBlank(value) || !idealList.contains(value.substring(1,2))) {
                sortedList.add(fundamentals.get(i));

                //change line of address
                changeLineAddresses(fundamentals.get(i), sortedList.size() - 1);
            }
        }
        // System.debug('Sorted foundations:');
        // System.debug(sortedList);
        return sortedList;
    }

    private static void removeBlankCardFromLine(List<Card> lineTo, Address adrTo) {
        Card cardOld = lineTo.get(adrTo.position);
        if (cardOld.isEmpty) {
            lineTo.remove(adrTo.position);
        }
    }

    private static List<String> getNearCards(String value) {
        String[] cardsValues = possiblePlaces.get(value);
        // System.debug('Value: ');
        //printList('Get Near Card: ', cardsValues);
        if (cardsValues != null) {
            if (cardsValues.size() > 0) {
                return cardsValues;
            }
        }
        return new List<String>();
    }

    class PossibleMovement{
        PossibleMovement(String cardFromValue, String cardFromAddress, String cardToValue, String cardToAddress) {
            this.cardFromValue = cardFromValue;
            this.cardFromAddress = cardFromAddress;
            this.cardToValue = cardToValue;
            this.cardToAddress = cardToAddress;
        }
        String cardFromValue;
        String cardFromAddress;
        String cardToValue;
        String cardToAddress;
    }    

    private static void initAvailableMoves() {

//        Description                   isEmpty Value	isKnown	isOpen
//        Cell w/o card	                TRUE	""	    FALSE	TRUE
//        Cell with closed unknown card	FALSE	""	    FALSE	FALSE
//        Cell with closed known card	FALSE	2p	    TRUE	FALSE
//        Cell with open unknown card	FALSE	""	    FALSE	TRUE
//        Cell with open known card	    FALSE	2P	    TRUE	TRUE

//      Cards with "_" (e.g. "_2H") at the beginning belong to possible movements to fundamentals

        // System.debug('Initiate Available Moves');
        possiblePlaces.put('AP', new String[] {'F0','F1','F2','F3','2D','2H'});
        possiblePlaces.put('AC', new String[] {'F0','F1','F2','F3','2D','2H'});
        possiblePlaces.put('AD', new String[] {'F0','F1','F2','F3','2P','2C'});
        possiblePlaces.put('AH', new String[] {'F0','F1','F2','F3','2P','2C'});
        possiblePlaces.put('2P', new String[] {'3D','3H','AP'});
        possiblePlaces.put('2C', new String[] {'3D','3H','AC'});
        possiblePlaces.put('2D', new String[] {'3P','3C','AD'});
        possiblePlaces.put('2H', new String[] {'3P','3C','AH'});

        possiblePlaces.put('3P', new String[] {'4D','4H','2P'});
        possiblePlaces.put('3C', new String[] {'4D','4H','2C'});
        possiblePlaces.put('3D', new String[] {'4P','4C','2D'});
        possiblePlaces.put('3H', new String[] {'4P','4C','2H'});

        possiblePlaces.put('4P', new String[] {'5D','5H','3P'});
        possiblePlaces.put('4C', new String[] {'5D','5H','3C'});
        possiblePlaces.put('4D', new String[] {'5P','5C','3D'});
        possiblePlaces.put('4H', new String[] {'5P','5C','3H'});

        possiblePlaces.put('5P', new String[] {'6D','6H','4P'});
        possiblePlaces.put('5C', new String[] {'6D','6H','4C'});
        possiblePlaces.put('5D', new String[] {'6P','6C','4D'});
        possiblePlaces.put('5H', new String[] {'6P','6C','4H'});

        possiblePlaces.put('6P', new String[] {'7D','7H','5P'});
        possiblePlaces.put('6C', new String[] {'7D','7H','5C'});
        possiblePlaces.put('6D', new String[] {'7P','7C','5D'});
        possiblePlaces.put('6H', new String[] {'7P','7C','5H'});

        possiblePlaces.put('7P', new String[] {'8D','8H','6P'});
        possiblePlaces.put('7C', new String[] {'8D','8H','6C'});
        possiblePlaces.put('7D', new String[] {'8P','8C','6D'});
        possiblePlaces.put('7H', new String[] {'8P','8C','6H'});

        possiblePlaces.put('8P', new String[] {'9D','9H','7P'});
        possiblePlaces.put('8C', new String[] {'9D','9H','7C'});
        possiblePlaces.put('8D', new String[] {'9P','9C','7D'});
        possiblePlaces.put('8H', new String[] {'9P','9C','7H'});

        possiblePlaces.put('9P', new String[] {'10D','10H','8P'});
        possiblePlaces.put('9C', new String[] {'10D','10H','8C'});
        possiblePlaces.put('9D', new String[] {'10P','10C','8D'});
        possiblePlaces.put('9H', new String[] {'10P','10C','8H'});

        possiblePlaces.put('10P', new String[] {'JD','JH','9P'});
        possiblePlaces.put('10C', new String[] {'JD','JH','9C'});
        possiblePlaces.put('10D', new String[] {'JP','JC','9D'});
        possiblePlaces.put('10H', new String[] {'JP','JC','9H'});

        possiblePlaces.put('JP', new String[] {'QD','QH','10P'});
        possiblePlaces.put('JC', new String[] {'QD','QH','10C'});
        possiblePlaces.put('JD', new String[] {'QP','QC','10D'});
        possiblePlaces.put('JH', new String[] {'QP','QC','10H'});

        possiblePlaces.put('QP', new String[] {'KD','KH','JP'});
        possiblePlaces.put('QC', new String[] {'KD','KH','JC'});
        possiblePlaces.put('QD', new String[] {'KP','KC','JD'});
        possiblePlaces.put('QH', new String[] {'KP','KC','JH'});

        possiblePlaces.put('KP', new String[] {'R0','R1','R2','R3','R4','R5','R6','QP'});
        possiblePlaces.put('KC', new String[] {'R0','R1','R2','R3','R4','R5','R6','QC'});
        possiblePlaces.put('KD', new String[] {'R0','R1','R2','R3','R4','R5','R6','QD'});
        possiblePlaces.put('KH', new String[] {'R0','R1','R2','R3','R4','R5','R6','QH'});

    } 

}