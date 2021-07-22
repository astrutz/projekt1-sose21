const fs = require('fs');
const path = require('path');

function setHistory(messageObject) {
    const directory = fs.readdirSync(__dirname);
    let history = { messages: [] };
    if(directory.includes('history.json')) {
        history = JSON.parse(fs.readFileSync(path.join(__dirname, 'history.json')));
    }
    history.messages.push(messageObject);
    fs.writeFileSync(path.join(__dirname, 'history.json'), JSON.stringify(history));
}

function getHistory() {
    const directory = fs.readdirSync(__dirname);
    if(directory.includes('history.json')) {
        return JSON.parse(fs.readFileSync(path.join(__dirname, 'history.json')));
    } else {
        return { messages: [] };
    }
}

module.exports = {
    setHistory,
    getHistory
};