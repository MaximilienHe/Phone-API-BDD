const { default: axios } = require("axios");
const mysql = require('mysql');


const fetchBrandsFromAPI = async () => {
  try {
    await new Promise(resolve => setTimeout(resolve, 5000));
    const response = await axios.get(process.env.API_URL + "brands/");
    console.log("Success Brands Fetch");
    return response.data;
  } catch (error) {
    console.error(error);
    return null;
  }
};

const fetchBrandFromAPI = async (url) => {
  try {
    await new Promise(resolve => setTimeout(resolve, 5000));
    const response = await axios.get(process.env.API_URL + "brand/" + url);
    console.log("Success Brand Fetch");
    return response.data;
  } catch (error) {
    console.error(error);
    return null;
  }
};

const fetchDeviceFromAPI = async (url) => {
  try {
    await new Promise(resolve => setTimeout(resolve, 5000));
    const response = await axios.get(process.env.API_URL + "device/" + url);
    console.log("Success Device Fetch");
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
      // console.log(results);
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

        // Define the SQL query for devices table
        const sql = `INSERT INTO devices (title, brand_name, img, img_url)
        VALUES (?, ?, ?, ?)`

        // Create a prepared statement for devices table
        connection.query(sql, [brand.data[i].name, row.name, brand.data[i].img, brand.data[i].img_url, JSON.stringify(brand.data[i].spec_detail)], (error, results) => {
          if (error) {
            console.log(error);
            return;
          }
          console.log("Success Device");
        });

        // Define the SQL query for devicesDetail table
        let deviceDetails = await fetchDeviceFromAPI(brand.data[i].url);
        const sql2 = `INSERT INTO devicesDetail (title, brand_name, img, img_url, spec_details)
        VALUES (?, ?, ?, ?, ?)`

        // Create a prepared statement for devicesDetail table
        connection.query(sql2, [deviceDetails.title, row.name, deviceDetails.img, deviceDetails.img_url, JSON.stringify(deviceDetails.spec_detail)], (error, results) => {
          if (error) {
            console.log(error);
            return;
          }
          console.log("Success Device Detail");
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
    console.error('Error fetching brands from API\n');
    return;
  } else {
    console.log('Fetched brands from API\n');
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