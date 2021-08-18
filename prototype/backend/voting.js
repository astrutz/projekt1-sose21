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
    // TODO
}

module.exports = {
    endVoting,
    addVote,
    getVoting,
  };