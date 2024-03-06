require('dotenv').config();
const express = require('express');
const app = express();
const db = require('./sources/db');
require('./sources/contractListener');

// Middleware per analizzare il corpo delle richieste JSON
app.use(express.json());
