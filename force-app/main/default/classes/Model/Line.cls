/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-11-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global with sharing class Line {
    public Line() {

    }
    global Line(Integer i) {
        this.id = i;
        this.value = new List<Card>();
    }
    global Integer id;
    global List<Card> value;
}