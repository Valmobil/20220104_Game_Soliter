import { LightningElement } from 'lwc';
import getNextField from '@salesforce/apex/SolitaireReturnNextField.getNextField'

export default class SolitaireMainField extends LightningElement {
    
    fields = [];
    fundamentals = [];
    cards = [];
    bears = '';
    error;

    handleLoad() {
        getNextField()
            .then(result => {
                this.bears = result;
            })
            .catch(error => {
                this.error = error;
            });
    }

    connectedCallback() {
        getNextField()
        .then(result => { 
            this.bears = result;
            console.log(result);
            console.log(JSON.parse(result));
            this.init(); 
        })
        .catch(error => { this.error = error; });
    }

    init() {
        let initialBoard = new BoardClass(0, 0);
        initialBoard.runnignTrack =  [["2D"],["","2P"],["","","8D"],["","","","9D"],["","","","","KD"],["","","","","","2C"],["","","","","","","9H"]];
        this.fields.push(initialBoard);
        //define fundamentals
        for (let i = 0; i < initialBoard.fundamental.length; i++) {
            let line = new Card(i, []);
            if (initialBoard.fundamental[i].length == 0) {
                const card = new Card('f_' + i + '_' + 0 ,'');
                line.value.push(card);
            } else {
                for (let j = 0; j < initialBoard.fundamental[i].length; j++) {
                    const card = new Card('f_' + i + '_' + j ,initialBoard.fundamentals[i][j]);
                    line.value.push(card);
                }
            }
            this.fundamentals.push(line);        
        }
        //define running board
        for (let i = 0; i < initialBoard.runnignTrack.length; i++) {
            let line = new Card(i, []);
            for (let j = 0; j < initialBoard.runnignTrack[i].length; j++) {
                const card = new Card('r_' + i + '_' + j ,initialBoard.runnignTrack[i][j]);
                line.value.push(card);
            }
            this.cards.push(line);
        }
        // console.log(this.cards);
        // console.log(this.fundamentals);
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