require('dotenv').config();

const mysql = require('mysql');
const express = require('express');
const cron = require('cron');
const app = express();

// Set up MySQL connection
const connection = mysql.createConnection({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME
});

// Connect to the database
connection.connect((err) => {
  if (err) {
    console.error('error connecting: ' + err.stack);
    return;
  }
  console.log('connected as id ' + connection.threadId);
});


const fetchAndSave = require('./fetch-and-save');

fetchAndSave(connection);

// Set up a new cron job to run every day at midnight
// const job = new cron.CronJob('0 0 * * *', fetchAndSave);

// Start the cron job
// job.start();

app.listen(8080, () => {
  console.log('App listening on port 8080');
});