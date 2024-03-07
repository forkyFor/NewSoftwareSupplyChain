require('dotenv').config();
const express = require('express');
const app = express();
require('./sources/contractListener');

// Middleware per analizzare il corpo delle richieste JSON
app.use(express.json());
