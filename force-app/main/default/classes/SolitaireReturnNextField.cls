/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-11-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class SolitaireReturnNextField {

    public static final Integer FUNDAMENTAL_SIZE = 4;
    public static final Integer RUNNING_SIZE = 7;

    @AuraEnabled(cacheable=true)
    public static String getNextField() {
        
        Field field = new Field();
        field.id = 0;
        field.parentId = 0;
        field.fundamental = new List<List<String>>();
        for (Integer i = 0; i < FUNDAMENTAL_SIZE; i++) {
            field.fundamental.add(new String[] {''});
        }
        field.runnignTrack = new List<List<String>>();
        for (Integer i = 0; i < RUNNING_SIZE; i++) {
            field.runnignTrack.add(new String[] {''});
        }
        String result = JSON.serialize(field);

        System.debug(field);
        System.debug(result);

        return result;
    }

    class Field {
        Integer id;
        Integer parentId;
        String[][] fundamental;
        String[] stockPail;
        String[][] runnignTrack;
    }

}
