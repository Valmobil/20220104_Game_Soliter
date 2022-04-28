/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-27-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global with sharing class Card {

    global String address;
    global String addressOriginal;
    global String value;
    global Boolean isEmpty = false;
    global Boolean isOpen = false;
    global Boolean isKnown = false;

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

    global String getCardSuit() {
        return this.value.right(1);
    }

    global String getCardCost() {
        return this.value.left(this.value.length() - 1);
    }

    global String getCompanionCard() {
        String cost = this.getCardCost();
        String suit = this.getCardSuit();
        
        if (suit == 'd') {
            suit = 'h';
        } else if (suit == 'h') {
            suit = 'd';
        } else if (suit == 'c') {
            suit = 'p';
        } else if (suit == 'p') {
            suit = 'c';
        }
        return cost + suit;
    } 

}