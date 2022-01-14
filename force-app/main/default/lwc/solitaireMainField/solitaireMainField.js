import { LightningElement, track } from 'lwc';
import getNextField from '@salesforce/apex/SolitaireReturnNextField.getNextField'

export default class SolitaireMainField extends LightningElement {
    
    fields = [];
    @track
    fundamentals = [];
    @track
    cards = [];
    currentField;
    error;
    inProgress = false;

    connectedCallback() {
        this.getNextFieldAndUpdate();
    }

    async getNextFieldAndUpdate() {
        try {
            const result = await getNextField();
            this.bears = result;
            this.currentField = JSON.parse(result);
        } catch(error) { 
            this.error = error; 
        };
        console.log('Apex answer');
        console.log(this.bears);
        console.log(this.currentField);

        this.initHtml(this.currentField);
    }

    initHtml(curBoard) {
        console.log('Start')
        console.log(curBoard)
        let initialBoard = curBoard;
        console.log(initialBoard)
        // initialBoard.runnignTrack =  [["2D"],["","2P"],["","","8D"],["","","","9D"],["","","","","KD"],["","","","","","2C"],["","","","","","","9H"]];
        this.fields.push(initialBoard);
        console.log('Fund')
        console.log(initialBoard.fundamental)
        //define fundamentals
        this.fundamentals = initialBoard.fundamental;
        console.log('Run')
        console.log(initialBoard.fundamental)
        console.log(this.cards  )
        //define running board
        for (let i = 0; i < initialBoard.runnignTrack.length; i++) {
            let line = new Card(i, []);
            for (let j = 0; j < initialBoard.runnignTrack[i].length; j++) {
                const card = new Card('r_' + i + '_' + j ,initialBoard.runnignTrack[i][j]);
                line.value.push(card);
            }
            this.cards.push(line);
        }
        console.log(this.cards);
        console.log(this.fundamentals);
        console.log(curBoard);
        console.log(initialBoard);
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
}