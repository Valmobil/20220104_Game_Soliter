import { LightningElement, track, wire } from 'lwc';
import getResults from '@salesforce/apex/SolitaireResults.getResults';
import { subscribe, publish, MessageContext } from 'lightning/messageService';
import SOLITAIRE_UPDATE_CHANNEL from '@salesforce/messageChannel/Solitaire_Game_Update__c';

export default class SolitaireRightFrame extends LightningElement {

   
    @wire(MessageContext)
    messageContext;
    currentBoardId;
    resultIndex = 0;
    @track
    results;

    connectedCallback() {
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
        //console.log('Event handler listener for event: "result"');
        //console.log(message);
        if (message.operator == 'result') {
            //console.log('Result update event handler:');
            this.currentBoardId = message.constant;
        } else if (message.operator == 'new') {
            this.results = null;
        }
    }

    handleClickOnNextBoardLink(event) {
        //console.log('handle click to next board');
        this.currentBoardId = this.clearBoardId(event.target.id)
        const payload = {
            operator: 'open',
            constant: this.currentBoardId
        };
        publish(this.messageContext, SOLITAIRE_UPDATE_CHANNEL, payload);
        this.getResultsFromApex();
        return false;
    }

    clearBoardId(boardId) {
        if (boardId.includes('-')) {
            boardId = boardId.substring(0, boardId.indexOf('-'));   
        }
        return boardId;
    }

    handleClick(event) {
        this.getResultsFromApex();
        return false;
    }

    getResultsFromApex() {
        getResults({boardId: this.currentBoardId})
            .then((result) => {
                this.results = result;
                //console.log('Result list of boards:');
                //console.log(this.results);
            })
            .catch((error) => {
                this.error = error;
                this.contacts = undefined;
            });
    }

    get totalCardsClass() {
        console.log('Class list: ');
        let result = this.results[this.resultIndex];
        if (this.results.length == this.resultIndex + 1) {
            this.resultIndex = 0;
        } else {
            this.resultIndex++;
        }
        //console.log('Completed:');
        //console.log(result);
        return `${result.Completed__c ? "bold" : "normal"} ${result.Min_Path__c ? "min-path" : "not-path"}`;
    }

}