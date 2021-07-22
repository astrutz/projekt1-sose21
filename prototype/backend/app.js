const express = require('express');
const history = require('./history');

const app = express();
const server = require('http').createServer(app);
const port = process.env.PORT || 3000;

//Socket Logic
const socketio = require('socket.io')(server);

socketio.on("connection", (userSocket) => {

  console.log('Socket connection established');

  // Listen to message event
  userSocket.on("send_message", (data) => {

    history.setHistory(JSON.parse(data));
    
    console.log('Received message', JSON.parse(data));
    // Send message to all sockets
    userSocket.broadcast.emit("receive_message", data);
  });
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