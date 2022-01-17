import { LightningElement, track } from 'lwc';
import getInitialBoard from '@salesforce/apex/SolitaireReturnNextField.getInitialBoard'
import openOneCard from '@salesforce/apex/SolitaireReturnNextField.openOneCard'
import SystemModstamp from '@salesforce/schema/Account.SystemModstamp';

export default class SolitaireMainField extends LightningElement {
    
    @track
    fundamentals = [];
    @track
    cards = [];
    boards = [];
    currentBoard;
    error;

    connectedCallback() {
        console.log('1.')

        this.getNextBoardAndUpdate();
    }

    async openOneCardOnBoard(cardId, value) {
        console.log('here')
        try {
            console.log(`boardId ${this.currentBoard.boardId} cardId ${cardId} cardValue: ${value}`)
            const result = await openOneCard({boardId: this.currentBoard.boardId, cardId: cardId, cardValue: value})
            this.currentBoard = JSON.parse(result);
        } catch(error) { 
            console.log('!!!error!!!')
            this.error = error; 
        };
        console.log(result);
        this.initHtml(this.currentBoard);
    }

    async getNextBoardAndUpdate() {
        try {
            const result = await getInitialBoard();
            this.currentBoard = JSON.parse(result);
        } catch(error) {
            this.error = error; 
            console.log(error);
        };
        this.initHtml(this.currentBoard);
    }

    initHtml(curBoard) {
        let initialBoard = curBoard;
        this.boards.push(initialBoard);
        //define fundamentals
        console.log(initialBoard)
        this.fundamentals = initialBoard.fundamental;
        //define running board
        for (let i = 0; i < initialBoard.runnignTrack.length; i++) {
            let line = new Card(i, []);
            for (let j = 0; j < initialBoard.runnignTrack[i].length; j++) {
                const card = new Card('r_' + i + '_' + j ,initialBoard.runnignTrack[i][j]);
                line.value.push(card);
            }
            this.cards.push(line);
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