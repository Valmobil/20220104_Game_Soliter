import { LightningElement, wire } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import SOLITAIRE_UPDATE_CHANNEL from '@salesforce/messageChannel/Solitaire_Game_Update__c';

export default class SolitaireTopFrame extends LightningElement {

    @wire(MessageContext)
    messageContext;

    newGameClick() {
      const payload = { 
        operator: 'new',
        constant: 1
      };
      publish(this.messageContext, SOLITAIRE_UPDATE_CHANNEL, payload);
    }
}