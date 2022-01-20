/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-20-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class SolitaireSolver {

    // String[] fig = ['A','2','3','4','5','6','7','8','9','10','J','Q','K'];
    // String[] type = ['P','C','D','H'];
    public static Map<String, String[]> possiblePlaces = new Map<String, String[]>();

    {
        initAvailableMoves();
    }

    public static void calculateVariarnts(SolitaireReturnNextField.Board board) {
        //map CardName and CardAddress
        Map<String, String> knownCards = new Map<String, String>();
        
        //set map of existing cards
        for (SolitaireReturnNextField.Line line : board.runnignTrack) {
            for (SolitaireReturnNextField.Card card : line.value) {
                knownCards.put(card.value, card.address);                
            }
        }

        //take one card and check for possible movements
        for (SolitaireReturnNextField.Line line : board.runnignTrack) {
            for (SolitaireReturnNextField.Card card : line.value) {
                SolitaireReturnNextField.Card[] nearCards = getNearCards(card.value);                
            }
        }
    }

    private static SolitaireReturnNextField.Card[] getNearCards(String value) {
        String[] cardsValue = possiblePlaces.get(value);
        // if (cards.length() > 0) {
        //     return cards;
        // }
        // return new SolitaireReturnNextField.Card[];
        return null;
    }



    private void initAvailableMoves() {
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
