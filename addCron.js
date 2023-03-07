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

const addCron = async (connection) => {
    // Fetch data from the API
    console.log("Starting cron job ... \n");
    const brands = await fetchBrandsFromAPI();

    if (!brands) {
        console.error('Error fetching brands from API\n');
        return;
    } else {
        console.log('Fetched brands from API\n');
    }

    // Check if there are new devices in the API
    for (let i = 0; i < brands.length; i++) {
        const brand = brands[i];
        const existingBrand = await new Promise((resolve, reject) => {
            const sql = `SELECT * FROM brands WHERE name = ?`;
            connection.query(sql, [brand.name], (error, results) => {
                if (error) {
                    reject(error);
                } else {
                    resolve(results[0]);
                }
            });
        });

        if (existingBrand) {
            const apiDevicesCount = parseInt(brand.devices);
            const bddDevicesCount = parseInt(existingBrand.devices);

            if (apiDevicesCount === bddDevicesCount) {
                console.log(`No new devices found for brand ${brand.name}\n`);
            } else {
                console.log(`New devices found for brand ${brand.name}\n`);
                let cptDevice = 0;
                let newDevicesCount = apiDevicesCount - bddDevicesCount;
                let deviceUrl = brand.url;

                while (cptDevice < newDevicesCount) {
                    const devices = await fetchBrandFromAPI(deviceUrl);
                    for (let j = 0; j < devices.length && cptDevice < newDevicesCount; j++) {
                        const device = devices[j];
                        const existingDevice = await new Promise((resolve, reject) => {
                            const sql = `SELECT * FROM devices WHERE title = ? AND brand_name = ?`;
                            connection.query(sql, [device.name, brand.name], (error, results) => {
                                if (error) {
                                    reject(error);
                                } else {
                                    resolve(results[0]);
                                }
                            });
                        });

                        if (!existingDevice) {
                            const sql = `INSERT INTO devices (title, brand_name, img, img_url)
                             VALUES (?, ?, ?, ?)`;
                            connection.query(sql, [device.name, brand.name, device.img, device.img_url], (error, results) => {
                                if (error) {
                                    console.log(error);
                                    return;
                                }
                                console.log("Success Device");
                            });

                            // Fetch device details from API
                            const deviceDetails = await fetchDeviceFromAPI(device.url);
                            const sql2 = `INSERT INTO devicesDetail (title, brand_name, img, img_url, spec_details)
                              VALUES (?, ?, ?, ?, ?)`;
                            connection.query(sql2, [deviceDetails.title, brand.name, deviceDetails.img, deviceDetails.img_url, JSON.stringify(deviceDetails.spec_detail)], (error, results) => {
                                if (error) {
                                    console.log(error);
                                    return;
                                }
                                console.log("Success Device Detail");
                            });

                            cptDevice++;
                        }
                    }

                    if (devices.next) {
                        deviceUrl = devices.next;
                    } else {
                        break;
                    }
                }
                // Update the devices count for the existing brand
                const sql3 = `UPDATE brands SET devices = ? WHERE name = ?`;
                connection.query(sql3, [apiDevicesCount, brand.name], (error, results) => {
                    if (error) {
                        console.log(error);
                        return;
                    }
                    console.log("Updated devices count for brand " + brand.name);
                });
            }
        }
    }
    console.log('Data saved successfully');
};



module.exports = addCron;