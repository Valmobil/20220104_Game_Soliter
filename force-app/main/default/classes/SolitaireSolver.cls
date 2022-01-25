/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-24-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class SolitaireSolver {

    public static Map<String, String[]> possiblePlaces = new Map<String, String[]>();

    static {
        System.debug('Start Initiate Available Moves');
        initAvailableMoves();
    }

    public static void calculateVariants(Board board) {
        
        //map CardName and CardAddress
        Map<String, String> knownCards = new Map<String, String>();
        List<PossibleMovement> possibleMovements = new List<PossibleMovement>();
        List<Id> newBoardsIds = new List<Id>(); 


        //set map of existing cards
        for (Line line : board.runnignTrack) {
            for (Card card : line.value) {
                if (card.isKnown == false && card.isOpen) {
                    return;
                }
                knownCards.put(card.value, card.address);               
            }
        }

        //take one card and check for possible movements
        for (Line line : board.runnignTrack) {
            for (Card card : line.value) {
                List<String> nearCards = getNearCards(card.value);
                for (String nearCard : nearCards) {
                    if (knownCards.containsKey(nearCard)) {
                        String address = knownCards.get(nearCard);
                        PossibleMovement pm = new PossibleMovement(card.value, card.address, nearCard, address);
                        possibleMovements.add(pm);
                    }
                }            
            }
        }
        System.debug('Possible movements');
        System.debug(possibleMovements);


        //generate new board for each movement
        for (PossibleMovement oneMove : possibleMovements) {
            Address adrCardFrom = new Address(oneMove.cardFromAddress);
            Address adrCardTo = new Address(oneMove.cardToAddress);
            System.debug('Possible Movements:');
            System.debug(oneMove);
            System.debug(adrCardFrom);
            System.debug(adrCardTo);

            Board newBoard = board.cloneBoard();
            System.debug('1.');
            if(moveCards(newBoard, adrCardFrom, adrCardTo)) {
                System.debug('2.');
                String result = JSON.serialize(newBoard);
                Solitair_Metadata__c boardDbNew = board.mapperBoardToBoardDb(board.gameId, 'Board', result);
                System.debug('3.');
                System.debug('boardDbNew:');
                System.debug(boardDbNew);
                insert boardDbNew;
            }
        }
    }




    private static Boolean moveCards(Board board, Address adrFrom, Address adrTo) {
        System.debug('1.0');
        // move fundamentals
        if (adrFrom.firstLetter == 'f') {
            System.debug('f1.0');
            List<Card> lineFrom = board.fundamental.get(adrFrom.lineNumber).value;
            if (lineFrom.size() != adrFrom.position + 1) {
                //we can move only the last card in line
                System.debug('f1.1');
                return false;
            } 
            if (adrTo.firstLetter == 's') {
                //we cannot move cards to stock pail
                System.debug('f1.2');
                return false;
            }
            List<Card> lineTo = board.runnignTrack.get(adrTo.lineNumber).value;
            if (adrTo.firstLetter == 'r') {
                //we can move only on the lates running cards
                if (lineTo.size() != adrTo.position + 1) {
                    //we can move only the last card in line
                    System.debug('f1.3');
                    return false;
                } 
            }
            // Move cards
            for (Integer i = adrFrom.position; i < lineFrom.size(); i++) {
                lineTo.add(lineFrom.get(i));
            }
            for (Integer i = adrFrom.position; i < lineFrom.size(); i++) {
                lineFrom.remove(adrFrom.position);
            }
            return true;
        }
        
        // move running pails
        if (adrFrom.firstLetter == 'r') {
            System.debug('r1.0');
            List<Card> lineFrom = board.runnignTrack.get(adrFrom.lineNumber).value;
            if (adrTo.firstLetter == 's') {
                //we cannot move cards to stock pail
                System.debug('r1.1');
                return false;
            }
            List<Card> lineTo = board.runnignTrack.get(adrTo.lineNumber).value;
            if (adrTo.firstLetter == 'f') {
                //we can move only on the lates running cards
                if (lineTo.size() != adrTo.position + 1) {
                    //we can move only the last card in line
                    System.debug('r1.2');
                    return false;
                } 
            }
            if (adrTo.firstLetter == 'r') {
                //we can move only on the lates running cards
                if (lineTo.size() != adrTo.position + 1) {
                    //we can move only the last card in line
                    System.debug('r1.3');
                    return false;
                } 
            }
            // Move cards
            System.debug('lineFrom:');
            System.debug(lineFrom);
            System.debug(adrFrom);
            System.debug('lineTo:');
            System.debug(lineTo);
            System.debug(adrTo);
            lineTo.add(lineFrom.get(adrFrom.position));
            lineFrom.remove(adrFrom.position);
            return true;
        }
        System.debug('2.0');
        return false;
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
        System.debug('Initiate Available Moves');
        possiblePlaces.put('AP', new String[] {'H0','H1','H2','H3','2D','2H'}); 
        possiblePlaces.put('AC', new String[] {'H0','H1','H2','H3','2D','2H'}); 
        possiblePlaces.put('AD', new String[] {'H0','H1','H2','H3','2P','2C'});
        possiblePlaces.put('AH', new String[] {'H0','H1','H2','H3','2P','2C'});
        possiblePlaces.put('2P', new String[] {'3D','3H'});
        possiblePlaces.put('2С', new String[] {'3D','3H'});
        possiblePlaces.put('2D', new String[] {'3P','3C'});
        possiblePlaces.put('2H', new String[] {'3P','3C'});

        possiblePlaces.put('3P', new String[] {'4D','4H'});
        possiblePlaces.put('3С', new String[] {'4D','4H'});
        possiblePlaces.put('3D', new String[] {'4P','4C'});
        possiblePlaces.put('3H', new String[] {'4P','4C'});

        possiblePlaces.put('4P', new String[] {'5D','5H'});
        possiblePlaces.put('4С', new String[] {'5D','5H'});
        possiblePlaces.put('4D', new String[] {'5P','5C'});
        possiblePlaces.put('4H', new String[] {'5P','5C'});

        possiblePlaces.put('5P', new String[] {'6D','6H'});
        possiblePlaces.put('5С', new String[] {'6D','6H'});
        possiblePlaces.put('5D', new String[] {'6P','6C'});
        possiblePlaces.put('5H', new String[] {'6P','6C'});

        possiblePlaces.put('6P', new String[] {'7D','7H'});
        possiblePlaces.put('6С', new String[] {'7D','7H'});
        possiblePlaces.put('6D', new String[] {'7P','7C'});
        possiblePlaces.put('6H', new String[] {'7P','7C'});

        possiblePlaces.put('7P', new String[] {'8D','8H'});
        possiblePlaces.put('7С', new String[] {'8D','8H'});
        possiblePlaces.put('7D', new String[] {'8P','8C'});
        possiblePlaces.put('7H', new String[] {'8P','8C'});

        possiblePlaces.put('6P', new String[] {'7D','7H'});
        possiblePlaces.put('6С', new String[] {'7D','7H'});
        possiblePlaces.put('6D', new String[] {'7P','7C'});
        possiblePlaces.put('6H', new String[] {'7P','7C'});

        possiblePlaces.put('7P', new String[] {'8D','8H'});
        possiblePlaces.put('7С', new String[] {'8D','8H'});
        possiblePlaces.put('7D', new String[] {'8P','8C'});
        possiblePlaces.put('7H', new String[] {'8P','8C'});

        possiblePlaces.put('8P', new String[] {'9D','9H'});
        possiblePlaces.put('8С', new String[] {'9D','9H'});
        possiblePlaces.put('8D', new String[] {'9P','9C'});
        possiblePlaces.put('8H', new String[] {'9P','9C'});

        possiblePlaces.put('9P', new String[] {'10D','10H'});
        possiblePlaces.put('9С', new String[] {'10D','10H'});
        possiblePlaces.put('9D', new String[] {'10P','10C'});
        possiblePlaces.put('9H', new String[] {'10P','10C'});

        possiblePlaces.put('10P', new String[] {'JD','JH'});
        possiblePlaces.put('10С', new String[] {'JD','JH'});
        possiblePlaces.put('10D', new String[] {'JP','JC'});
        possiblePlaces.put('10H', new String[] {'JP','JC'});

        possiblePlaces.put('JP', new String[] {'QD','QH'});
        possiblePlaces.put('JС', new String[] {'QD','QH'});
        possiblePlaces.put('JD', new String[] {'QP','QC'});
        possiblePlaces.put('JH', new String[] {'QP','QC'});

        possiblePlaces.put('QP', new String[] {'KD','KH'});
        possiblePlaces.put('QС', new String[] {'KD','KH'});
        possiblePlaces.put('QD', new String[] {'KP','KC'});
        possiblePlaces.put('QH', new String[] {'KP','KC'});

        possiblePlaces.put('KP', new String[] {'R0','R1','R2','R3','R4','R5','R6'});
        possiblePlaces.put('KС', new String[] {'R0','R1','R2','R3','R4','R5','R6'});
        possiblePlaces.put('KD', new String[] {'R0','R1','R2','R3','R4','R5','R6'});
        possiblePlaces.put('KH', new String[] {'R0','R1','R2','R3','R4','R5','R6'});

    } 
}