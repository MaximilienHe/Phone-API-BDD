const {
    default: axios
} = require("axios");
const mysql = require('mysql');

const fetchBrandsFromAPI = async () => {
    try {
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

    let newDeviceNames = []; // tableau pour stocker les ID des nouveaux devices

    console.log("Starting cron job ... \n");
    const brands = await fetchBrandsFromAPI();

    if (!brands) {
        console.error('Error fetching brands from API\n');
        return;
    } else {
        console.log('Fetched brands from API\n');
    }

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

        let bddDevicesCount = 0;

        const apiDevicesCount = parseInt(brand.devices);
        if (brand.name == "Amazon" || brand.name == "Asus" || brand.name == "Blackview" || brand.name == "Cat" || brand.name == "Doogee" || brand.name == "Fairphone" || brand.name == "Google" || brand.name == "Honor" || brand.name == "HTC" || brand.name == "Huawei" || brand.name == "Lenovo" || brand.name == "Meizu" || brand.name == "Microsoft" || brand.name == "Motorola" || brand.name == "Nokia" || brand.name == "Nothing" || brand.name == "OnePlus" || brand.name == "Oppo" || brand.name == "Realme" || brand.name == "Samsung" || brand.name == "Sony" || brand.name == "TCL" || brand.name == "vivo" || brand.name == "Wiko" || brand.name == "Xiaomi" || brand.name == "ZTE") {
            bddDevicesCount = parseInt(existingBrand.devices);
            if (apiDevicesCount === bddDevicesCount) {
                console.log(`No new devices found for brand ${brand.name}\n`);
            } else if (apiDevicesCount > bddDevicesCount) {
                console.log(`New devices found for brand ${brand.name}. Nb devices API : ${apiDevicesCount} vs Nb devices BDD : ${bddDevicesCount}\n`);
                let cptDevice = 0;
                let newDevicesCount = apiDevicesCount - bddDevicesCount;
                let deviceUrl = brand.url;

                while (cptDevice < newDevicesCount) {
                    const devices = await fetchBrandFromAPI(deviceUrl);
                    for (let j = 0; j < devices.data.length && cptDevice < newDevicesCount; j++) {
                        const device = devices.data[j];
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
                            console.log("Adding device " + device.name + " for brand " + brand.name + " ... \n")
                            let brand_name = brand.name;
                            if (brand_name === "O") {
                                brand_name = "O2";
                            }
                            const sql = `INSERT INTO devices (title, brand_name, img, description)
                            VALUES (?, ?, ?, ?)
                            ON DUPLICATE KEY UPDATE img=VALUES(img), description=VALUES(description)`;
                            await new Promise((resolve, reject) => {
                                connection.query(sql, [brand_name + " " + device.name, brand.name, device.img, device.description], (error, results) => {
                                    if (error) {
                                        console.log(error);
                                        reject(error);
                                        return;
                                    }
                                    // Si un nouveau device est ajouté, on récupère son title pour l'ajouter au tableau
                                    if (results.affectedRows === 1) {
                                        newDeviceNames.push(brand_name + " " + device.name);
                                    }
                                    console.log("Success Device");
                                    resolve();
                                });
                            });

                            // Fetch device details from API
                            console.log("Adding device details for device " + device.name + " for brand " + brand.name + " ... \n")
                            const deviceDetails = await fetchDeviceFromAPI(device.url);

                            for (const category of deviceDetails.spec_detail) {
                                const categoryName = category.category;
                                const specs = category.specs;

                                // Insert or update category
                                // const sqlCategory = `INSERT INTO categories (device_title, name)
                                //                 VALUES (?, ?)
                                //                 ON DUPLICATE KEY UPDATE name = VALUES(name)`;
                                // await new Promise((resolve, reject) => {
                                //     connection.query(sqlCategory, [deviceDetails.title, category.category], (error, results) => {
                                //         if (error) {
                                //             console.log(error);
                                //             reject(error);
                                //             return;
                                //         }
                                //         console.log("Success Category");
                                //         resolve();
                                //     });
                                // });

                                for (const spec of specs) {
                                    const specName = spec.name;
                                    const specValue = spec.value;

                                    // Insert or update spec
                                    const sqlSpec = `INSERT IGNORE INTO specs (device_title, category_name, name, value)
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

                            cptDevice++;
                            console.log("Number of devices added : " + cptDevice + " / " + newDevicesCount + "\n");
                        }
                        if (j === devices.data.length - 1) {
                            console.log("End of for loop");
                            cptDevice = newDevicesCount
                        }
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

    let promiseArray = [];

    for (let deviceName of newDeviceNames) {
        const sql = `CALL call_all_procedures_device_title(?)`;
        promiseArray.push(new Promise((resolve, reject) => {
            connection.query(sql, [deviceName], (error, results) => {
                if (error) {
                    console.log(error);
                    reject(error);
                } else {
                    console.log("Success Calling Stored Procedure for Device ID: " + deviceName);
                    resolve();
                }
            });
        }));
    }

    const sql = `CALL delete_tests_specs()`;
    promiseArray.push(new Promise((resolve, reject) => {
        connection.query(sql, (error, results) => {
            if (error) {
                console.log(error);
                reject(error);
            } else {
                console.log("Success Calling Stored Procedure delete_tests_specs");
                resolve();
            }
        });
    }));

    const sql2 = `CALL delete_useless_devices()`;
    promiseArray.push(new Promise((resolve, reject) => {
        connection.query(sql2, (error, results) => {
            if (error) {
                console.log(error);
                reject(error);
            } else {
                console.log("Success Calling Stored Procedure delete_useless_devices");
                resolve();
            }
        });
    }));

    Promise.all(promiseArray)
        .then(() => {
            console.log('Data cleaned successfully');
            process.exit();
        })
        .catch((error) => {
            console.error('There was an error: ', error);
        });
};

module.exports = addCron;