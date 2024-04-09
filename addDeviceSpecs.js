const fs = require("fs");
const axios = require("axios");
const mysql = require("mysql");

const fetchAndSaveDeviceSpecs = async (connection, filePath) => {
  try {
    // Lecture du fichier contenant les noms des smartphones
    const deviceNames = fs.readFileSync(filePath, "utf-8").split("\n");

    for (const deviceName of deviceNames) {
      // Remplacer les espaces par %20 pour l'URL
      const formattedName = deviceName.trim().replace(/\s/g, "%20");
      const apiUrl = process.env.API_URL + `/search/${formattedName}`;

      // Récupération des données de l'API
      const response = await axios.get(apiUrl);
      const deviceData = response.data;

      if (deviceData) {
        // Ici, insérez les données dans la base de données
        console.log(`Adding or updating device specs for: ${deviceName}`);
        const deviceTitle = deviceName; // Utilisez le titre approprié pour votre cas

        // Insérer ou mettre à jour les spécifications du dispositif
        for (const category of deviceData.spec_detail) {
          for (const spec of category.specs) {
            const sqlSpec = `INSERT INTO specs (device_title, category_name, name, value)
                             VALUES (?, ?, ?, ?)
                             ON DUPLICATE KEY UPDATE value = VALUES(value)`;
            await new Promise((resolve, reject) => {
              connection.query(
                sqlSpec,
                [deviceTitle, category.category, spec.name, spec.value],
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

        console.log(
          `Successfully added/updated device specs for: ${deviceName}`
        );
      } else {
        console.error(`No data found for device: ${deviceName}`);
      }
    }
  } catch (error) {
    console.error("Error:", error);
  }
};

module.exports = fetchAndSaveDeviceSpecs;

// Exemple d'utilisation
// fetchAndSaveDeviceSpecs('/path/to/your/devices.txt');
