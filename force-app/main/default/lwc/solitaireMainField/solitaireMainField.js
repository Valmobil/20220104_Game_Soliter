import { LightningElement, track, wire } from 'lwc';
import getInitialBoard from '@salesforce/apex/SolitaireReturnNextField.getInitialBoard'
import openOneCard from '@salesforce/apex/SolitaireReturnNextField.openOneCard'
import openSelectedBoard from '@salesforce/apex/SolitaireReturnNextField.openSelectedBoard'
import { subscribe, publish, MessageContext } from 'lightning/messageService';
import SOLITAIRE_UPDATE_CHANNEL from '@salesforce/messageChannel/Solitaire_Game_Update__c';

export default class SolitaireMainField extends LightningElement {
    
    @track
    fundamentals = [];
    @track
    cards = [];
    @track
    stocks = [];
    currentBoard;
    error;
    subscription = null;
    @wire(MessageContext)
    messageContext;
    alreadyUsed = new Set();


    connectedCallback() {
        this.subscribeToMessageChannel();
        this.getNextBoardAndUpdate();
    }

    renderedCallback() {
        //console.log('RenderCallBack: list of elements:');
        let ni = this.template.querySelectorAll('.app-stock-pail');
        let i = 0;
        ni.forEach(element => {
            if (i > 0) {
                element.style.marginTop = '-30px';
            }
            i++;
            //console.log(element.tagName);  
        });
    }

    subscribeToMessageChannel() {
      this.subscription = subscribe(
        this.messageContext,
        SOLITAIRE_UPDATE_CHANNEL,
        (message) => this.handleMessage(message)
      );
    }

    handleMessage(message) {
        //console.log('Listen for event - Solitaire Main Field');
        if (message.operator == 'new') {
            //console.log('New game initiated');
            this.getNextBoardAndUpdate();
        } else if (message.operator == 'open') {
            //console.log('Open board');
            this.openExistingBoard(message.constant);
        }
    }

    async openOneCardOnBoard(cardAddress, value) {
        try {
            //console.log(`gameId ${this.currentBoard.gameId} cardAddress ${cardAddress} cardValue: ${value}`)
            const result = await openOneCard({gameId: this.currentBoard.gameId, boardId: this.currentBoard.boardId, cardAddress: cardAddress, cardValue: value})
            this.currentBoard = JSON.parse(result);
            this.alreadyUsed.add(value);

            //fire event for right frame on result update
            const payload = {
                operator: 'result',
                constant: this.currentBoard.boardId
              };
              publish(this.messageContext, SOLITAIRE_UPDATE_CHANNEL, payload);
        } catch(error) { 
            console.log('!!!error on backend!!!')
            this.error = error; 
        };
        this.initHtml(this.currentBoard);
    }

    async getNextBoardAndUpdate() {
        try {
            //console.log('getInitialBoard:');
            const result = await getInitialBoard();
            this.currentBoard = JSON.parse(result);
            this.alreadyUsed = this.updateAlreadyInUseCardList(this.currentBoard);
        } catch(error) {
            this.error = error; 
            console.log(error);
        };
        this.initHtml(this.currentBoard);
    }

    updateAlreadyInUseCardList(currentBoard) {
        let alreadyInUse = new Set();
        for (let line of currentBoard.fundamental) {
            for (let card of line.value) {
                if (card.isKnown) {
                    alreadyInUse.add(card.value);
                }
            }
        }

        for (let line of currentBoard.runningTrack) {
            //console.log(line['value'])
            for (let card of line.value) {
                if (card.isKnown) {
                    alreadyInUse.add(card.value);
                }
            }
        }
        for (let line of currentBoard.stockPail) {
            for (let card of line.value) {
                if (card.isKnown) {
                    alreadyInUse.add(card.value);
                }
            }
        }
        return alreadyInUse;
    }

    async openExistingBoard(boardId) {
        try {
            //console.log('Open_Board:');
            //console.log(boardId);
            const result = await openSelectedBoard({boardId: boardId});
            // console.log('result: ' + result);
            this.currentBoard = JSON.parse(result);
            this.alreadyUsed = this.updateAlreadyInUseCardList(this.currentBoard);
        } catch(error) {
            this.error = error;
            console.log(error);
        };
        this.initHtml(this.currentBoard);
    }

    initHtml(curBoard) {
        if (curBoard) {
            let initialBoard = curBoard;
            //console.log(`initialBoard: ${initialBoard}`);
            //console.log(initialBoard);

            //define fundamentals
            if (initialBoard.fundamental) {
                this.fundamentals = initialBoard.fundamental;
            }
            //define running board
            if(initialBoard.runningTrack) {
                this.cards = initialBoard.runningTrack;
            }
            //define stocks
            if(initialBoard.stockPail) {
                this.stocks = initialBoard.stockPail;
            }
            //console.log("this stocks: ")
            //console.log(this.stocks);
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
                const txt = fig[i] + type[j];
                if (!this.alreadyUsed.has(txt)) {
                    arr.push({ label: txt, value: txt });
                } 
            }            
        }
        return arr;
    }

    handleChange(event) {
        // console.log('this.handleChange')
        // console.log(event.target.dataset.item);
        // console.log(event.detail.value)
        // console.log(event.detail.address)
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
        this.runningTrack = [[],[],[],[],[],[],[]];
        this.gameId;
    }
}

// cуперкласс for one card on board
function Card(id, value) {
    this.id = id;
    this.value = value;
    this.isEmpty = true;
}