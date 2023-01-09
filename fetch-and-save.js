const { default: axios } = require("axios");
const mysql = require('mysql');


const fetchBrandsFromAPI = async () => {
    try {
      const response = await axios.get(process.env.API_URL + "brands/");
      return response.data;
    } catch (error) {
        console.error(error);
        return null;
    }
  };
  
  const insertBrandsIntoDatabase = (data, connection, callback) => {
    // Insert the data into the database
    for (const row of data) {
        // Define the SQL query
        const sql = `
        INSERT INTO brands (name, devices)
        VALUES (?, ?)
        ON DUPLICATE KEY UPDATE name = ?, devices = ?;
        `;
        // Create a prepared statement
        const preparedStatement = mysql.format(sql, [row.name, row.devices, row.name, row.devices]);

        // Execute the prepared statement
        connection.query(preparedStatement, (error, results) => {
            if (error) {
            console.error(error);
            return;
            }
        
            console.log(results);
        }); 
    };
  };
  
  const fetchAndSave = async (connection) => {
    // Fetch data from the API
    const brands = await fetchBrandsFromAPI();
    if (!brands) {
      console.error('Error fetching brands from API');
      return;
    }
    // Insert the data into the database
    insertBrandsIntoDatabase(brands, connection, (err) => {
      if (err) {
        console.error('Error inserting data into database');
        return;
      }
  
      console.log('Data saved successfully');
    });
  };
  
  module.exports = fetchAndSave;