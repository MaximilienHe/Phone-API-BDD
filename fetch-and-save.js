const {
  default: axios
} = require("axios");
const mysql = require('mysql');

const getNextPageUrl = (pages) => {
  if (pages) {
    for (let i = 0; i < pages.length - 1; i++) {
      if (pages[i].active) {
        return pages[i + 1].url;
      }
    }
  } else {
    return null;
  }
};

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
  for (let iBrand = 0; iBrand < data.length; iBrand++) {
    console.log("Brand " + (iBrand + 1) + " / " + data.length + " : " + data[iBrand].name);
    //  
    // if (data[iBrand].name == "Amazon" || data[iBrand].name == "Asus" || data[iBrand].name == "Blackview" || data[iBrand].name == "Cat" || data[iBrand].name == "Doogee" || data[iBrand].name == "Fairphone" || data[iBrand].name == "Google" || data[iBrand].name == "Honor" || data[iBrand].name == "HTC" || data[iBrand].name == "Huawei" || data[iBrand].name == "Lenovo" || data[iBrand].name == "Meizu" || data[iBrand].name == "Microsoft" || data[iBrand].name == "Motorola" || data[iBrand].name == "Nokia" || data[iBrand].name == "Nothing" || data[iBrand].name == "OnePlus" || data[iBrand].name == "Oppo" || data[iBrand].name == "Realme" || data[iBrand].name == "Samsung" || data[iBrand].name == "Sony" || data[iBrand].name == "TCL" || data[iBrand].name == "vivo" || data[iBrand].name == "Wiko" || data[iBrand].name == "Xiaomi" || data[iBrand].name == "ZTE") {
    if (data[iBrand].name == "Samsung") {
      console.log("Valid brand");
    } else {
      console.log("Invalid brand");
      continue;
    }
    console.log("Brand name : " + data[iBrand].name + " ; Devices : " + data[iBrand].devices);
    // Insert brand data
    const sql = `INSERT INTO brands (name, devices) 
    VALUES (?, ?) 
    ON DUPLICATE KEY UPDATE devices = IF(devices = VALUES(devices), devices, VALUES(devices))`;
    const preparedStatement = mysql.format(sql, [data[iBrand].name, data[iBrand].devices]);
    connection.query(preparedStatement, (error, results) => {
      if (error) {
        console.error(error);
        return;
      }
    });

    let brand = await fetchBrandFromAPI(data[iBrand].url);
    while (!brand.data[0].url) {
      console.error('Error fetching brand from API');
      brand = await fetchBrandFromAPI(data[iBrand].url);
    }

    let deviceCount = 0;
    do {
      for (let i = 0; i < brand.data.length; i++) {
        deviceCount++;
        console.log("Brand name : " + data[iBrand].name + " ; Device " + deviceCount + " / " + data[iBrand].devices);
        let brand_name = data[iBrand].name;
        if (brand_name === "O") {
          brand_name = "O2";
        }
        // Insert device data
        if (brand_name + " " + brand.data[i].name == "Samsung Galaxy Tab Active4 Pro" ||
         brand_name + " " + brand.data[i].name == "Samsung Galaxy A04s" ||
         brand_name + " " + brand.data[i].name == "Samsung Galaxy Watch5 Pro" ||
         brand_name + " " + brand.data[i].name == "Samsung Galaxy Watch5" ||
         brand_name + " " + brand.data[i].name == "Samsung Galaxy A23 5G" ||
         brand_name + " " + brand.data[i].name == "OnePlus Nord Watch" ||
         brand_name + " " + brand.data[i].name == "Samsung Galaxy A02s" ||
         brand_name + " " + brand.data[i].name == "Realme C55" ||
         brand_name + " " + brand.data[i].name == "Realme C1" ||
         brand_name + " " + brand.data[i].name == "Samsung Galaxy A51 5G" ||
         brand_name + " " + brand.data[i].name == "Samsung Galaxy S8 Active" ||
         brand_name + " " + brand.data[i].name == "Samsung Galaxy J5 Prime") {
          console.log("Valid device : " + brand.data[i].name);
        // const sql = `INSERT INTO devices (title, brand_name, img, description)
        // VALUES (?, ?, ?, ?)`;
        // await new Promise((resolve, reject) => {
        //   connection.query(sql, [brand_name + " " + brand.data[i].name, data[iBrand].name, brand.data[i].img, brand.data[i].description], (error, results) => {
        //     if (error) {
        //       console.log(error);
        //       reject(error);
        //       return;
        //     }
        //     console.log("Success Device");
        //     resolve();
        //   });
        // });

        // Fetch device details
        let deviceDetails = await fetchDeviceFromAPI(brand.data[i].url);
        for (let category of deviceDetails.spec_detail) {

          // Insert specs data
          for (let spec of category.specs) {
            const sqlSpec = `INSERT INTO specs (device_title, category_name, name, value)
            VALUES (?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE value = VALUES(value)`;
            connection.query(sqlSpec, [deviceDetails.title, category.category, spec.name, spec.value], (error, results) => {
              if (error) {
                console.log(error);
                return;
              }
              console.log("Success Spec");
            });
          }
        }
      }
      }

      const nextPageUrl = getNextPageUrl(brand.pages);
      if (nextPageUrl) {
        brand = await fetchBrandFromAPI(nextPageUrl);
      } else {
        break;
      }

    } while (true);
  }
  if (callback) {
    callback();
  }
};


const fetchLastPageDevices = async (connection) => {
  const brands = await fetchBrandsFromAPI(connection);
  for (let iBrand = 9; iBrand < brands.length; iBrand++) {
    console.log("Brand " + iBrand + " / " + brands.length + " : " + brands[iBrand].name)
    let brand = await fetchBrandFromAPI(brands[iBrand].url);
    while (!brand.data[0].url) {
      console.error('Error fetching brand from API');
      brand = await fetchBrandFromAPI(brands[iBrand].url);
    }

    // Recherche de la dernière page de la marque
    let lastPageUrl = null;
    if (brand.pages) {
      lastPageUrl = brand.pages[brand.pages.length - 1].url;
      console.log("Last page url : " + lastPageUrl);
    } else {
      console.log("No pages for brand " + brands[iBrand].name);
      continue;
    }

    if (lastPageUrl) {
      // Récupérer les appareils de la dernière page
      const lastPageDevices = await fetchBrandFromAPI(lastPageUrl);
      for (let i = 0; i < lastPageDevices.data.length; i++) {
        console.log("Brand name : " + brands[iBrand].name + " ; Device " + i + " / " + lastPageDevices.data.length);
        // Insérer les données de l'appareil dans la base de données
        let brand_name = brands[iBrand].name;
        if (brand_name === "O") {
          brand_name = "O2";
        }
        const sql = `INSERT INTO devices (title, brand_name, img, description)
        VALUES (?, ?, ?, ?)`;
        await new Promise((resolve, reject) => {
          connection.query(sql, [brand_name + " " + lastPageDevices.data[i].name, brands[iBrand].name, lastPageDevices.data[i].img, lastPageDevices.data[i].description], (error, results) => {
            if (error) {
              console.log(error);
              reject(error);
              return;
            }
            console.log("Success Device");
            resolve();
          });
        });

        // Fetch device details
        let deviceDetails = await fetchDeviceFromAPI(lastPageDevices.data[i].url);
        for (let category of deviceDetails.spec_detail) {
          // Insert category data
          const sqlCategory = `INSERT INTO categories (device_title, name)
          VALUES (?, ?)
          ON DUPLICATE KEY UPDATE name = VALUES(name)`;
          await new Promise((resolve, reject) => {
            connection.query(sqlCategory, [deviceDetails.title, category.category], (error, results) => {
              if (error) {
                console.log(error);
                reject(error);
                return;
              }
              console.log("Success Category");
              resolve();
            });
          });

          // Insert specs data
          for (let spec of category.specs) {
            const sqlSpec = `INSERT INTO specs (device_title, category_name, name, value)
            VALUES (?, ?, ?, ?)
            ON DUPLICATE KEY UPDATE value = VALUES(value)`;
            connection.query(sqlSpec, [deviceDetails.title, category.category, spec.name, spec.value], (error, results) => {
              if (error) {
                console.log(error);
                return;
              }
              console.log("Success Spec");
            });
          }
        }
      }
    } else {
      console.log("No last page");
      continue;
    }
  }
};

module.exports = {
  insertBrandsIntoDatabase,
  fetchBrandsFromAPI,
  fetchLastPageDevices
};