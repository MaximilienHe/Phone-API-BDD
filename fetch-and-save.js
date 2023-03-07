const {
  default: axios
} = require("axios");
const mysql = require('mysql');


const fetchBrandsFromAPI = async () => {
  try {
    // Add delay of 5 to 10 seconds
    const delay = Math.floor(Math.random() * 6) + 5;
    await new Promise(resolve => setTimeout(resolve, delay * 1000));
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
    // Add delay of 5 to 10 seconds
    const delay = Math.floor(Math.random() * 6) + 5;
    await new Promise(resolve => setTimeout(resolve, delay * 1000));
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
    // Add delay of 5 to 10 seconds
    const delay = Math.floor(Math.random() * 6) + 5;
    await new Promise(resolve => setTimeout(resolve, delay * 1000));
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
  let cptDevice = 0;
  for (let iBrand = 62; iBrand < data.length; iBrand++) {
    cptDevice = 0;

    ////////////////////////////////////////
    //                BRANDS              //
    ////////////////////////////////////////

    // Define the SQL query
    const sql = `INSERT INTO brands (name, devices) 
    VALUES (?, ?) 
    ON DUPLICATE KEY UPDATE devices = IF(devices = VALUES(devices), devices, VALUES(devices))`;
    // Create a prepared statement
    const preparedStatement = mysql.format(sql, [data[iBrand].name, data[iBrand].devices]);

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

    let brand = await fetchBrandFromAPI(data[iBrand].url);
    while (!brand.data[0].url) {
      console.error('Error fetching brand from API');
      brand = await fetchBrandFromAPI(data[iBrand].url);
    }
    do {
      for (let i = 0; i < brand.data.length; i++) {
        cptDevice++;
        console.log("Brand name : " + data[iBrand].name + " ; Device " + cptDevice + " / " + data[iBrand].devices);
        // Define the SQL query for devices table
        const sql = `INSERT INTO devices (title, brand_name, img, img_url)
        VALUES (?, ?, ?, ?)`

        // Create a prepared statement for devices table
        connection.query(sql, [brand.data[i].name, data[iBrand].name, brand.data[i].img, brand.data[i].img_url, JSON.stringify(brand.data[i].spec_detail)], (error, results) => {
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
        connection.query(sql2, [deviceDetails.title, data[iBrand].name, deviceDetails.img, deviceDetails.img_url, JSON.stringify(deviceDetails.spec_detail)], (error, results) => {
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
    } while (data[iBrand].devices > cptDevice);

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