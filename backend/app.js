const express = require('express');
const cors = require('cors');

// INITIALIZATION
const app = express();

// INIT ROUTES
const routes = require('./routes');

// MIDDLEWARES
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use('/uploads', express.static('uploads'));
app.use(routes);

// SERVER LISTENER
app.listen(3000, () => {
  console.log(`Server running at http://localhost:3000`);
})


// NOTE : 
// -----------------------------------------------------------
// NDAK USAH DI UTAK ATIK BAGIAN APP JS
// ----------------------------------------------------------