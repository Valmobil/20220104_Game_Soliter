import { LightningElement, track, wire } from 'lwc';
import getResults from '@salesforce/apex/SolitaireResults.getResults';
import { subscribe, publish, MessageContext } from 'lightning/messageService';
import SOLITAIRE_UPDATE_CHANNEL from '@salesforce/messageChannel/Solitaire_Game_Update__c';

export default class SolitaireRightFrame extends LightningElement {

    @track
    results = [];
    @wire(MessageContext)
    messageContext;
    gameId;

    connectedCallback() {
        console.log('1.')
        this.subscribeToMessageChannel();
    }

    subscribeToMessageChannel() {
        this.subscription = subscribe(
          this.messageContext,
          SOLITAIRE_UPDATE_CHANNEL,
          (message) => this.handleMessage(message)
        );
      }

    handleMessage(message) {
        console.log('Event handler listener for event: "result"');
        console.log(message);
        if (message.operator == 'result') {
            console.log('Result update event handler:');
            this.gameId = message.constant;
            console.log('GameId: ' + this.gameId);
            //this.getResultsFromApex(gameId);
        }
    }

    handleClickOnNextBoardLink(event) {
        console.log('handle click to next board');
        console.log(event.target.id);

        const payload = {
            operator: 'open',
            constant: event.target.id
        };
        publish(this.messageContext, SOLITAIRE_UPDATE_CHANNEL, payload);

        return false;
    }

    handleClick(event) {
        this.getResultsFromApex();
        // this.clickedButtonLabel = event.target.label;
    }

    getResultsFromApex() {
        getResults({gameId: this.gameId})
            .then((result) => {
                this.results = JSON.parse(result);

            })
            .catch((error) => {
                this.error = error;
                this.contacts = undefined;
            });
    }


//    async getResultsFromApex(gameId) {
//        try {
//            console.log('getResults:');
////            const result = await getResults(gameId);
//            const result = await testConnection(gameId);
//            console.log('result: ' + result);
////            this.results = JSON.parse(result);
////            console.log(this.results);
//        } catch(error) {
//            this.error = error;
//            console.log(error);
//        };
//    }

}