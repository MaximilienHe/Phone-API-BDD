require('dotenv').config();
const mysql = require('mysql');
const express = require('express');
const app = express();
const cron = require('cron');
const { insertBrandsIntoDatabase, fetchBrandsFromAPI, fetchLastPageDevices } = require('./fetch-and-save');

const addCron = require('./addCron');

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


addCron(connection);

// Code for initial fetch and save

// (async () => {
//   const brandsData = await fetchBrandsFromAPI();
//   if (brandsData) {
//     insertBrandsIntoDatabase(brandsData, connection, () => {
//       connection.end();
//     });
//   } else {
//     console.error("Failed to fetch brands from API");
//     connection.end();
//   }
// })();

// fetchLastPageDevices(connection);


app.listen(8080, () => {
  console.log('App listening on port 8080');
});