import { LightningElement, track, wire } from 'lwc';
import getInitialBoard from '@salesforce/apex/SolitaireReturnNextField.getInitialBoard'
import openOneCard from '@salesforce/apex/SolitaireReturnNextField.openOneCard'
import { subscribe, MessageContext } from 'lightning/messageService';
import SOLITAIRE_UPDATE_CHANNEL from '@salesforce/messageChannel/Solitaire_Game_Update__c';

export default class SolitaireMainField extends LightningElement {
    
    @track
    fundamentals = [];
    @track
    cards = [];
    currentBoard;
    error;
    subscription = null;
    @wire(MessageContext)
    messageContext;


    connectedCallback() {
        console.log('1.')
        this.subscribeToMessageChannel();
        this.getNextBoardAndUpdate();
    }

    subscribeToMessageChannel() {
      this.subscription = subscribe(
        this.messageContext,
        SOLITAIRE_UPDATE_CHANNEL,
        (message) => this.handleMessage(message)
      );
    }
    handleMessage(message) {
        console.log('New game initiated');
        if (message.operator == 'new') {
            this.getNextBoardAndUpdate();
        }
    }

    async openOneCardOnBoard(cardAddress, value) {
        console.log('here')
        try {
            console.log(`boardId ${this.currentBoard.boardId} cardAddress ${cardAddress} cardValue: ${value}`)
            const result = await openOneCard({boardId: this.currentBoard.boardId, cardAddress: cardAddress, cardValue: value})
            this.currentBoard = JSON.parse(result);
        } catch(error) { 
            console.log('!!!error!!!')
            this.error = error; 
        };
        console.log(this.currentBoard);
        this.initHtml(this.currentBoard);
    }

    async getNextBoardAndUpdate() {
        try {
            console.log('getInitialBoard:');
            const result = await getInitialBoard();
            console.log('result: ' + result);
            this.currentBoard = JSON.parse(result);
            console.log(this.currentBoard);
        } catch(error) {
            this.error = error; 
            console.log(error);
        };
        this.initHtml(this.currentBoard);
    }

    initHtml(curBoard) {
        if (curBoard) {
            let initialBoard = curBoard;
            console.log(`initialBoard: ${initialBoard}`);
            console.log(initialBoard);

            //define fundamentals
            if (initialBoard.fundamental) {
                this.fundamentals = initialBoard.fundamental;
            }
            //define running board
            if(initialBoard.runnignTrack) {
                this.cards = initialBoard.runnignTrack;
            }
            console.log("this cards: ")
            console.log(this.cards);
        } else {
            console.log('Current board is empty (in initHtml)');
        }
    }

    get options() {
        let fig = ['A','2','3','4','5','6','7','8','9','10','J','Q','K'];
        let type = ['P','C','D','H'];
        let arr= [];
        for (let i = 0; i < fig.length; i++) {
            for (let j = 0; j < type.length; j++) {
                arr.push({ label: fig[i] + type[j], value: fig[i] + type[j] }); 
            }            
        }
        return arr;9
    }

    handleChange(event) {
        console.log('this.handleChange')
        console.log(event.target.dataset.item);
        console.log(event.detail.value)
        this.openOneCardOnBoard(event.target.dataset.item, event.detail.value);
    }
}


// суперкласс for game board snapshort
class BoardClass {
    constructor(id, parentId) {
        this.id = id;
        this.parentId = parentId;
        this.fundamental = [[],[],[],[]];
        this.stockPail = [];
        this.runnignTrack = [[],[],[],[],[],[],[]];
    }
}

// cуперкласс for one card on board
function Card(id, value) {
    this.id = id;
    this.value = value;
    this.isEmpty = true;
}