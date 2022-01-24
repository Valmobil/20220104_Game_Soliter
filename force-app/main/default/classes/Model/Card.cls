/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-24-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global with sharing class Card {
    public Card() {

    }
    global Card(String address, String value) {
        this.address = address;
        if (String.isEmpty(value)) {
            this.value = '';
            this.isKnown = false; 
        } else {
            this.value = value;
            this.isKnown = true; 
        }
    }

    global void setAddress(String address) {
        address = address;
    }

    global String address;
    global String value;
    global Boolean isEmpty = false;
    global Boolean isOpen = false;
    global Boolean isKnown = false;
}
