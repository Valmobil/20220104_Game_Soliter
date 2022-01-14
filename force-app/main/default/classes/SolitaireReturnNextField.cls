/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-14-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class SolitaireReturnNextField {

    public static final Integer FUNDAMENTAL_SIZE = 4;
    public static final Integer RUNNING_SIZE = 7;
    public static Integer uniqueIndex = 0;

    @AuraEnabled(cacheable=true)
    public static String getNextField() {
        
        Field field = new Field();
        field.id = 0;
        field.parentId = 0;
        field.fundamental = new List<Line>();
        System.debug('Empty Fund:');
        System.debug(field.fundamental);
        for (Integer i = 0; i < FUNDAMENTAL_SIZE; i++) {
            System.debug(field.fundamental);
            //Add fundamental lines
            Line line = new Line(i);
            field.fundamental.add(line);

            //add card to line
            Card card = new Card();
            card.id = uniqueIndex;
            uniqueIndex++;
            card.address = 'f_' + i + '_0';
            card.value = '';
            card.isEmpty = true;
            field.fundamental.get(i).value.add(card);

            //add second card to line - for test purposes
            card = new Card();
            card.id = uniqueIndex;
            uniqueIndex++;
            card.address = 'f_' + i + '_1';
            card.value = '';
            card.isEmpty = true;
            field.fundamental.get(i).value.add(card);
        }
        field.runnignTrack = new List<List<String>>();
        for (Integer i = 0; i < RUNNING_SIZE; i++) {
            field.runnignTrack.add(new String[] {''});
        }
        field.stockPail = new List<String>();
        field.stockPail.add('');
        String result = JSON.serialize(field);

        return result;
    }

    class Field {
        Integer id;
        Integer parentId;
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
