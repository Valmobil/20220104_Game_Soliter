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
        let initialBoard = curBoard;
        // initialBoard.runnignTrack =  [["2D"],["","2P"],["","","8D"],["","","","9D"],["","","","","KD"],["","","","","","2C"],["","","","","","","9H"]];
        this.fields.push(initialBoard);
        console.log('Fund')
        console.log(initialBoard.fundamental)
        //define fundamentals
        for (let i = 0; i < initialBoard.fundamental.length; i++) {
            console.log('in loop')
            let line = new Card(i, []);
            if (initialBoard.fundamental[i].length == 0) {
                console.log('If true')
                const card = new Card('f_' + i + '_' + 0 ,'');
                line.value.push(card);
            } else {
                console.log('If false')
                console.log(initialBoard.fundamental[i]);
                for (let j = 0; j < initialBoard.fundamental[i].length; j++) {
                    console.log('second for ')
                    console.log(i);
                    console.log(j);
                    console.log(initialBoard.fundamental[i])
                    console.log(initialBoard.fundamental[i][j])
                    const card = new Card('f_' + i + '_' + j ,initialBoard.fundamental[i][j]);
                    line.value.push(card);
                }
            }
            this.fundamentals.push(line);        
        }
        console.log('Run')
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