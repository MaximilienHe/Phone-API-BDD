const fs = require("fs");
const axios = require("axios");
const mysql = require("mysql");

const fetchAndSaveDeviceSpecs = async (connection, filePath) => {
  try {
    // Lecture du fichier contenant les noms des smartphones
    const deviceNames = fs.readFileSync(filePath, "utf-8").split("\n");

    for (const deviceName of deviceNames) {
      const formattedName = deviceName.trim().replace(/\s/g, "%20");
      const searchApiUrl = process.env.API_URL + `search/${formattedName}`;

      // Récupération des informations générales de l'API
      const searchResponse = await axios.get(searchApiUrl);
      const searchResults = searchResponse.data;

      // Trouver le dispositif correspondant exactement par le nom
      const exactMatchDevice = searchResults.find(device => device.name === deviceName.trim());

      if (exactMatchDevice) {
        const deviceDetailsApiUrl = process.env.API_URL + `device/${exactMatchDevice.url}`;

        // Récupération des détails de l'appareil de l'API
        const detailsResponse = await axios.get(deviceDetailsApiUrl);
        const deviceDetails = detailsResponse.data;

        console.log(`Adding or updating device specs for: ${deviceName}`);
        
        if (deviceDetails && deviceDetails.spec_detail) {
          // Insérer ou mettre à jour les spécifications du dispositif
          for (const category of deviceDetails.spec_detail) {
            for (const spec of category.specs) {
              const sqlSpec = `INSERT INTO specs (device_title, category_name, name, value)
                               VALUES (?, ?, ?, ?)
                               ON DUPLICATE KEY UPDATE value = VALUES(value)`;
              await new Promise((resolve, reject) => {
                connection.query(
                  sqlSpec,
                  [deviceName, category.category, spec.name, spec.value],
                  (error) => {
                    if (error) {
                      reject(error);
                      return;
                    }
                    resolve();
                  }
                );
              });
            }
          }
          console.log(`Successfully added/updated device specs for: ${deviceName}`);
        } else {
          console.error(`No details found for device: ${deviceName}`);
        }
      } else {
        console.error(`No exact match found for device: ${deviceName}`);
      }
    }
  } catch (error) {
    console.error("Error:", error);
  }
};

module.exports = fetchAndSaveDeviceSpecs;

// Exemple d'utilisation
// N'oubliez pas d'initialiser et de passer la connexion MySQL et le chemin du fichier
// fetchAndSaveDeviceSpecs(connection, '/path/to/your/devices.txt');
