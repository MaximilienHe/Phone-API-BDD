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

const fetchBrandFromAPI = async (url) => {
  try {
    const response = await axios.get(process.env.API_URL + "brand/" + url);
    console.log(process.env.API_URL + "brand/" + url);
    // console.log(response.data.data);
    return response.data;
  } catch (error) {
    console.error(error);
    return null;
  }
};

const fetchDeviceFromAPI = async (url) => {
  try {
    const response = await axios.get(process.env.API_URL + "device/" + url);
    return response.data;
  } catch (error) {
    console.error(error);
    return null;
  }
};

const insertBrandsIntoDatabase = async (data, connection, callback) => {
  // Insert the data into the database
  let id = 0;
  for (const row of data) {
    ////////////////////////////////////////
    //                BRANDS              //
    ////////////////////////////////////////
    
    // Define the SQL query
    const sql = `INSERT INTO brands (name, devices) 
    VALUES (?, ?) 
    ON DUPLICATE KEY UPDATE devices = IF(devices = VALUES(devices), devices, VALUES(devices))`;
    // Create a prepared statement
    const preparedStatement = mysql.format(sql, [row.name, row.devices]);
    
    // Execute the prepared statement
    connection.query(preparedStatement, (error, results) => {
      if (error) {
        console.error(error);
        return;
      }
      console.log(results);
    });   
    
    ////////////////////////////////////////
    //                DEVICES             //
    ////////////////////////////////////////
    

    let brand = await fetchBrandFromAPI(row.url);
    while (!brand.data[0].url) {
      console.error('Error fetching brand from API');
      brand = await fetchBrandFromAPI(row.url);
    }
    do {
      for (let i = 0; i < brand.data.length; i++) {
        // let deviceDetails = await fetchDeviceFromAPI(brand.data[i].url);
        // while (!deviceDetails.title) {
        //   console.error('Error fetching device from API');
        //   deviceDetails = await fetchDeviceFromAPI(brand.data[i].url);
        // }
        
        const sql = `INSERT INTO devices (title, brand_name, img, img_url)
        VALUES (?, ?, ?, ?) `
        
        connection.query(sql, [brand.data[i].name, row.name, brand.data[i].img, brand.data[i].img_url], (error, results) => {
          if (error) {
            console.log(error);
            return;
          }
          console.log("Success");
        });
      }
      if (brand.next) {
        brand = await fetchBrandFromAPI(brand.next);
        while (!brand.data[0].url) {
          console.error('Error fetching brand from API');
          brand = await fetchBrandFromAPI(brand.next);
        }
      }
  } while (brand.next);
    
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