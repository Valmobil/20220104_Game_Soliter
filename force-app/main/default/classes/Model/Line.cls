/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-24-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global with sharing class Line {
    public Line() {

    }
    global Line(Integer i) {
        this.id = i;
        this.value = new List<Card>();
    }
    Integer id;
    global List<Card> value;
}