const fs = require('fs');
const path = require('path');

function addVote(voteID) {
    const directory = fs.readdirSync(__dirname);
    let voting = { votes: {} };
    if(directory.includes('voting.json')) {
        voting = JSON.parse(fs.readFileSync(path.join(__dirname, 'voting.json')));
    }
    if(voting.votes[voteID]) {
        voting.votes[voteID] = voting.votes[voteID] + 1;
    } else {
        voting.votes[voteID] = 1;
    }
    fs.writeFileSync(path.join(__dirname, 'voting.json'), JSON.stringify(voting));
}

function getVoting() {
    const directory = fs.readdirSync(__dirname);
    if(directory.includes('voting.json')) {
      return JSON.parse(fs.readFileSync(path.join(__dirname, 'voting.json')));
    } else {
      return { votes: {} };
    }
}

function endVoting() {
    const directory = fs.readdirSync(__dirname);
    if(directory.includes('voting.json')) {
        const voteData = JSON.parse(fs.readFileSync(path.join(__dirname, 'voting.json')));
        let biggestKey = -1;
        let biggestValue = 0;
        Object.keys(voteData.votes).forEach((key) => {
            if(voteData.votes[key] > biggestValue) {
                biggestKey = key;
            }
        });
        return biggestKey;
    } else {
      return -1;
    }
}

module.exports = {
    endVoting,
    addVote,
    getVoting,
  };