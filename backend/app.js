require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const cookieParser = require('cookie-parser');
const deliveryRoute = require('./routes/delivery');
const auth = require('./routes/auth');
const PORT = process.env.PORT || 3000;
const DB_URL = process.env.DB_URL || "mongodb://127.0.0.1:27017/backend";

const app = express();

app.use(express.json());
app.use(cookieParser());
app.use(express.urlencoded({ extended: false }));

mongoose.connect(DB_URL)
    .then(() => console.log("Connected to the DB"))
    .then((result)=> app.listen(PORT))
    .catch((err) => console.log({ "Error": err }));

// app.get('*', checkUser);

app.use('/delivery-Info', deliveryRoute);

app.use('/user', auth);