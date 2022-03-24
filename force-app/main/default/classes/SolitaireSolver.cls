/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-24-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class SolitaireSolver {

    public static Map<String, String[]> possiblePlaces = new Map<String, String[]>();

    static {
        System.debug('Start Initiate Available Moves');
        initAvailableMoves();
    }

    public static List<Board> calculateVariants(Board board) {

        List<Board> boardsNew = new List<Board>();

        //set map of existing cards running tracks
        Map<String, String> knownCards = collectExistingCardsList(board);
        if (knownCards == null) {
            return new List<Board>();
        }

        //take one card and check for possible movements
        List<PossibleMovement> possibleMovements = preparePossibleMovements(board, knownCards);

        printList('Possible movements:', possibleMovements);
        if (possibleMovements.size() > 10) {
            return null;
        }


        //generate new board for each movement
        for (PossibleMovement oneMove : possibleMovements) {
            
            Address adrCardFrom = new Address(oneMove.cardFromAddress);
            Address adrCardTo = new Address(oneMove.cardToAddress);
            System.debug(adrCardFrom);
            System.debug(adrCardTo);
            Board newBoard = board.cloneBoard();
            newBoard.lastMove = board.level + '.' + oneMove.cardFromValue + '(' + adrCardFrom.toString() + ')->' + oneMove.cardToValue + '(' + adrCardTo.toString() + ')';
            if(moveCards(newBoard, adrCardFrom, adrCardTo)) {

                newBoard.fundamental = normalizeFoundation(newBoard.fundamental);
                newBoard.key = generateBoardVariantKey(newBoard);
                if (haveNoSuchVariant(newBoard)) {

                    String result = JSON.serialize(newBoard);
                    Solitair_Metadata__c boardDbNew = board.mapperBoardToBoardDb(board.gameId, 'Board', result, newBoard.key);
                    insert boardDbNew;

                    //run variant calculation
                    newBoard.boardId = boardDbNew.id;
                    boardsNew.add(newBoard);
                }
                if (boardsNew.size() > 10) {
                    System.debug('Limit q-ty of boards:' + boardsNew.size());
                    break;
                }
            }
        }
        return boardsNew;
    }

    public static String generateBoardVariantKey(Board board) {
        String key = '';
        key+= 'Run:';
        key+= addCardValue(board.runningTrack);
        
        key+= 'Sto:';
        key+= addCardValue(board.stockPail);

        key+= 'Fun:';
        key+= addCardValue(board.fundamental);

        System.debug('Board Variant Key:');
        System.debug(key);
        return key;
    }

    private static String addCardValue(List<Line> pail) {
        String str = '';
        for (Line line : pail) {
            str+= '_';
            for (Card card : line.value) {
                if(card.isKnown) {
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

    private static Boolean haveNoSuchVariant(Board board) {
        System.debug('Have no such variant:');
        System.debug(board.key);
        List<Solitair_Metadata__c> boardList = [select id from Solitair_Metadata__c where Key__c = :board.key and Solitair_Game_Id__c = :board.gameId];
        if (boardList.size() == 0) {
            boardList = [select id, key__c from Solitair_Metadata__c where Solitair_Game_Id__c = :board.gameId];
            System.debug('List of existing boards:');
            for (Solitair_Metadata__c boardMy : boardList) {
                System.debug(boardMy.id + '_' + boardMy.key__c);
            }

            System.debug('have no board');
            return true;
        } else {
            System.debug('board exists');
            return false;
        }
    }

    private static List<PossibleMovement> preparePossibleMovements(Board board, Map<String, String> knownCards) {
        List<PossibleMovement> possibleMovements = new List<PossibleMovement>();

        //running track possible movements
        for (Line line : board.runningTrack) {
            for (Card card : line.value) {
                findPossibleMovements(possibleMovements, card, knownCards);
            }
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
                    
                    System.debug('!!!! Rotate !!!!');
                    System.debug('Card');
                    System.debug(card);
                    System.debug(cardTo);
                    
                    PossibleMovement pm = new PossibleMovement(card.value, card.address, cardTo.value, cardTo.address);
                    possibleMovements.add(pm);  
                }
            }
        }


        printList('Possible movements list:', possibleMovements);
        
        return possibleMovements;
    }

    private static void printList(String name, List<Object> lst) {
        System.debug(name);
        for (Object obj : lst) {
            System.debug(obj);
        }
    }


    private static void findPossibleMovements(List<PossibleMovement> possibleMovements, Card card, Map<String, String> knownCards) {
        List<String> nearCards = getNearCards(card.value);
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
                if (addrTo.firstLetter == 'R') {
                    if (card.value.charAt(card.value.length() - 1) == nearCard.charAt(nearCard.length() - 1)) {
                        //if Running card has same type
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
                if (card.isKnown || card.isEmpty) {
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
        for (Integer i = 0; i < board.stockPail.size(); i++) {
            Line line = board.stockPail.get(i);
            for (Card card : line.value) {
                if (card.isKnown == false && card.isOpen) {
                    //if we have at least one open but unknown card, stop analysis
                    return null;
                }
                String cardName = card.value;
                if (String.isBlank(cardName) && card.isEmpty) {
                    //if cell is blank fill with virtual card name
                    cardName = 'S' + i;
                }
                if (card.isKnown || card.isEmpty) {
                    //add only known cards and blank cells
                    knownCards.put(card.value, card.address);
                }
            }
        }
        return knownCards;
    }

    private static void changeLineAddresses(Line line, Integer lineNum) {
        for (Card card : line.value) {
            Address addressNew = new Address(card.address);
            addressNew.lineNumber = lineNum;
            card.address = addressNew.toString();
        }
    }

    private static Boolean moveCards(Board board, Address adrFrom, Address adrTo) {
        System.debug('Move Cards from: ' + adrFrom.toString() + ' to: ' + adrTo.toString());
        
        // move fundamentals
        if (adrFrom.firstLetter == 'f') {
            List<Card> lineFrom = board.fundamental.get(adrFrom.lineNumber).value;
            if (lineFrom.size() != adrFrom.position + 1) {
                //we can move only the last card in line
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
            }
            // Move cards
            removeBlankCardFromLine(lineTo, adrTo);
            Card card = lineFrom.get(adrFrom.position);

            //change address (addressOriginal w/o changes)
            Address addressNew = new Address(adrTo);
            addressNew.position = lineTo.size();
            card.address = addressNew.toString();

            lineTo.add(card);
            lineFrom.remove(adrFrom.position);

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
            System.debug('Move from Stock Pail = ');
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
            }

            // Move cards
            System.debug('Move ST');
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

            if (lineFrom.size() > 10 || lineTo.size() > 10) {
                printList('Line from:', lineFrom);
                printList('Line to:', lineTo);
                return;
            }

            //change address (addressOriginal w/o changes)
            Address addressNew = new Address(adrTo);
            addressNew.position = lineTo.size();
            card.address = addressNew.toString(); 
            //add card
            

            if (lineFrom.size() > 10 || lineTo.size() > 10) {
                printList('Line from:', lineFrom);
                printList('Line to:', lineTo);
                return;
            }

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
            }
        }
        System.debug('Sorted foundations:');
        System.debug(sortedList);
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



        System.debug('Initiate Available Moves');
        possiblePlaces.put('AP', new String[] {'F0','F1','F2','F3','2D','2H'});
        possiblePlaces.put('AC', new String[] {'F0','F1','F2','F3','2D','2H'});
        possiblePlaces.put('AD', new String[] {'F0','F1','F2','F3','2P','2C'});
        possiblePlaces.put('AH', new String[] {'F0','F1','F2','F3','2P','2C'});
        possiblePlaces.put('2P', new String[] {'3D','3H','AP'});
        possiblePlaces.put('2С', new String[] {'3D','3H','AC'});
        possiblePlaces.put('2D', new String[] {'3P','3C','AD'});
        possiblePlaces.put('2H', new String[] {'3P','3C','AH'});

        possiblePlaces.put('3P', new String[] {'4D','4H','2P'});
        possiblePlaces.put('3С', new String[] {'4D','4H','2C'});
        possiblePlaces.put('3D', new String[] {'4P','4C','2D'});
        possiblePlaces.put('3H', new String[] {'4P','4C','2H'});

        possiblePlaces.put('4P', new String[] {'5D','5H','3P'});
        possiblePlaces.put('4С', new String[] {'5D','5H','3C'});
        possiblePlaces.put('4D', new String[] {'5P','5C','3D'});
        possiblePlaces.put('4H', new String[] {'5P','5C','3H'});

        possiblePlaces.put('5P', new String[] {'6D','6H','4P'});
        possiblePlaces.put('5С', new String[] {'6D','6H','4C'});
        possiblePlaces.put('5D', new String[] {'6P','6C','4D'});
        possiblePlaces.put('5H', new String[] {'6P','6C','4H'});

        possiblePlaces.put('6P', new String[] {'7D','7H','5P'});
        possiblePlaces.put('6С', new String[] {'7D','7H','5C'});
        possiblePlaces.put('6D', new String[] {'7P','7C','5D'});
        possiblePlaces.put('6H', new String[] {'7P','7C','5H'});

        possiblePlaces.put('7P', new String[] {'8D','8H','6P'});
        possiblePlaces.put('7С', new String[] {'8D','8H','6C'});
        possiblePlaces.put('7D', new String[] {'8P','8C','6D'});
        possiblePlaces.put('7H', new String[] {'8P','8C','6H'});

        possiblePlaces.put('8P', new String[] {'9D','9H','7P'});
        possiblePlaces.put('8С', new String[] {'9D','9H','7C'});
        possiblePlaces.put('8D', new String[] {'9P','9C','7D'});
        possiblePlaces.put('8H', new String[] {'9P','9C','7H'});

        possiblePlaces.put('9P', new String[] {'10D','10H','8P'});
        possiblePlaces.put('9С', new String[] {'10D','10H','8C'});
        possiblePlaces.put('9D', new String[] {'10P','10C','8D'});
        possiblePlaces.put('9H', new String[] {'10P','10C','8H'});

        possiblePlaces.put('10P', new String[] {'JD','JH','9P'});
        possiblePlaces.put('10С', new String[] {'JD','JH','9C'});
        possiblePlaces.put('10D', new String[] {'JP','JC','9D'});
        possiblePlaces.put('10H', new String[] {'JP','JC','9H'});

        possiblePlaces.put('JP', new String[] {'QD','QH','10P'});
        possiblePlaces.put('JС', new String[] {'QD','QH','10C'});
        possiblePlaces.put('JD', new String[] {'QP','QC','10D'});
        possiblePlaces.put('JH', new String[] {'QP','QC','10H'});

        possiblePlaces.put('QP', new String[] {'KD','KH','JP'});
        possiblePlaces.put('QС', new String[] {'KD','KH','JC'});
        possiblePlaces.put('QD', new String[] {'KP','KC','JD'});
        possiblePlaces.put('QH', new String[] {'KP','KC','JH'});

        possiblePlaces.put('KP', new String[] {'R0','R1','R2','R3','R4','R5','R6','QP'});
        possiblePlaces.put('KС', new String[] {'R0','R1','R2','R3','R4','R5','R6','QC'});
        possiblePlaces.put('KD', new String[] {'R0','R1','R2','R3','R4','R5','R6','QD'});
        possiblePlaces.put('KH', new String[] {'R0','R1','R2','R3','R4','R5','R6','QH'});

    } 

}