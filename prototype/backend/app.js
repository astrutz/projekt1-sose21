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

      history.setHistory(data);
      
      console.log('Received message', data);
      // Send message to all sockets
      userSocket.broadcast.emit("receive_message", data);
    });
});

server.listen(port, () => {
  console.log(`Server running on port: ${port}`);
});