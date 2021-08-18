const express = require('express');
const history = require('./history');
const voting = require('./voting');

const app = express();
const server = require('http').createServer(app);
const port = process.env.PORT || 3000;

//Socket Logic
const socketio = require('socket.io')(server);

socketio.on("connection", (userSocket) => {

  console.log('Socket connection established');

  // Listen to message event
  userSocket.on("send_message", (data) => {

    const parsedData = JSON.parse(data);

    if(parsedData.endVote) {
      const voteWinner = voting.endVoting();
      console.log('Vote won by',voteWinner);
      userSocket.broadcast.emit("receive_voting", voteWinner);
    } else if(parsedData.voteID) {
      voting.addVote(parsedData.voteID);
    }

    history.setHistory(parsedData);
    
    console.log('Received message', parsedData);
    // Send message to all sockets
    userSocket.broadcast.emit("receive_message", data);
  });
});

app.get('/voting', (req, res) => {
  const currentVotes = voting.getVoting();
  res.send(currentVotes);
});

app.get('/history', (req, res) => {
  const messages = history.getHistory();
  res.send(messages);
});

app.delete('/history', (req, res) => {
  history.deleteHistory();
  res.sendStatus(200);
});

server.listen(port, () => {
  console.log(`Server running on port: ${port}`);
});