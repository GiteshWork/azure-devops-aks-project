const express = require('express');
const cors = require('cors');
const app = express();
const port = 8080;

app.use(cors());

app.get('/', (req, res) => {
  res.send('Hello from the backend API!');
});

app.listen(port, () => {
  console.log(`API server listening at http://localhost:${port}`);
});
// Triggering a new build