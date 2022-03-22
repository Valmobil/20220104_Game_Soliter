/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-18-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global with sharing class Address {

    global String firstLetter;
    global Integer lineNumber;
    global Integer position;

    public Address() {
    }

    public Address(String addr) {
        Integer firstIndex = addr.indexOf('_');
        Integer secondIndex = addr.indexOf('_', firstIndex + 1);
        this.firstLetter = addr.substring(0,firstIndex);
        this.lineNumber = Integer.valueOf(addr.substring(firstIndex + 1,secondIndex));
        this.position = Integer.valueOf(addr.substring(secondIndex + 1, addr.length()));
    }
    
    public Address(Address addr) {
        this.firstLetter = addr.firstLetter;
        this.lineNumber = addr.lineNumber;
        this.position = addr.position;
    }

    public override String toString() {
        return this.firstLetter + '_' + this.lineNumber + '_' + this.position;
    }
}