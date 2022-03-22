/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-18-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global with sharing class Card {
    public Card() {
        this.value = '';
    }
    global Card(String address, String value) {
        this.address = address;
        this.addressOriginal = address;
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
    global String addressOriginal;
    global String value;
    global Boolean isEmpty = false;
    global Boolean isOpen = false;
    global Boolean isKnown = false;
}