const fs = require('fs');

async function setHistory(messageObject) {
    // if history
    const directory = fs.readdirSync('/');
    console.log('DIR', directory);
    let history = { messages: [] };
    if(directory.includes('history.json')) {
        history = JSON.parse(fs.readFileSync('history.json'));
    }
    history.messages.push(messageObject);
    fs.writeFileSync('history.json', JSON.stringify(history));
}

async function getHistory() {
    
}

module.exports = {
    setHistory,
    getHistory
};