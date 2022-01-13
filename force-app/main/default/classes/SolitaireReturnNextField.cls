/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-13-2022
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
        field.fundamental = new List<List<Card>>();
        for (Integer i = 0; i < FUNDAMENTAL_SIZE; i++) {
            Card card = new Card();
            card.id = uniqueIndex;
            uniqueIndex++;
            card.address = 'f_' + i + '0';
            field.fundamental.add(new List<Card>());
            field.fundamental.get(i).add(card);
        }
        field.runnignTrack = new List<List<String>>();
        for (Integer i = 0; i < RUNNING_SIZE; i++) {
            field.runnignTrack.add(new String[] {''});
        }
        field.stockPail = new List<String>();
        field.stockPail.add('');
        String result = JSON.serialize(field);

        System.debug(field);
        System.debug(result);

        return result;
    }

    class Field {
        Integer id;
        Integer parentId;
        List<List<Card>> fundamental;
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

}
