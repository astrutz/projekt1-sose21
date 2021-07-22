const fs = require('fs');
const path = require('path');

async function setHistory(messageObject) {
    // if history
    const directory = fs.readdirSync(__dirname);
    console.log('DIR', directory);
    let history = { messages: [] };
    if(directory.includes('history.json')) {
        history = JSON.parse(fs.readFileSync(path.join(__dirname, 'history.json')));
    }
    history.messages.push(messageObject);
    fs.writeFileSync(path.join(__dirname, 'history.json'), JSON.stringify(history));
}

async function getHistory() {
    
}

module.exports = {
    setHistory,
    getHistory
};