require('dotenv').config();
const axios = require('axios');
const mysql = require('mysql');

const connection = mysql.createConnection({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME
});

// Connectez-vous à la base de données
connection.connect(function (err) {
    if (err) throw err;
    console.log('Connecté à la base de données MySQL');
});

// Sélectionnez tous les noms de produits dans la table "devices"
connection.query('SELECT title FROM devices WHERE devices.announced_date IS NULL', function (error, results, fields) {
    if (error) throw error;

    // Définissez un index pour parcourir les résultats
    let index = 0;

    // Définissez une fonction récursive pour traiter chaque résultat
    function processResult() {
        if (index >= results.length) {
            console.log('Toutes les mises à jour ont été effectuées');
            return;
        }

        // Récupérez le nom de l'appareil à partir du résultat
        const device = results[index];

        // Récupérez les informations de l'appareil à partir de l'API
        axios.get(process.env.API_URL + `search/${device.title}`)
            .then(function (response) {
                // Recherchez l'URL du détail de l'appareil en filtrant les résultats par nom exact
                const deviceDetailUrl = response.data.find(result => result.name === device.title).url;
                axios.get(process.env.API_URL + `device/${deviceDetailUrl}`)
                    .then(function (response) {
                        // Récupérez la valeur de "Announced" à partir de la réponse de l'API
                        const announcedValue = getAnnouncedValue(response.data.spec_detail);
                        console.log(announcedValue + "\n");
                        // Mettez à jour la base de données avec la valeur de "Announced"   
                        const query = `UPDATE specs SET value = '${announcedValue}' WHERE specs.device_title = "${device.title}" AND specs.name = "Announced"`;
                        connection.query(query, function (error, results, fields) {
                            console.log(results);
                            if (error) throw error;
                            console.log(`Mise à jour de l'appareil ${device.title}`);

                            // Passez au résultat suivant après un délai aléatoire entre 5 et 10 secondes
                            setTimeout(processResult, Math.floor(Math.random() * 5000) + 5000);
                        });
                    })
                    .catch(function (error) {
                        console.log(error);

                        // Passez au résultat suivant après un délai aléatoire entre 5 et 10 secondes
                        setTimeout(processResult, Math.floor(Math.random() * 5000) + 5000);
                    });
            })
            .catch(function (error) {
                console.log(error);

                // Passez au résultat suivant après un délai aléatoire entre 5 et 10 secondes
                setTimeout(processResult, Math.floor(Math.random() * 5000) + 5000);
            });

        // Incrémentez l'index
        index++;
    }

    // Commencez le traitement des résultats
    processResult();
});

// Fonction pour récupérer la valeur de "Announced" à partir de la réponse de l'API
function getAnnouncedValue(specDetail) {
    for (let i = 0; i < specDetail.length; i++) {
        const category = specDetail[i];
        if (category.category === 'Launch') {
            for (let j = 0; j < category.specs.length; j++) {
                const spec = category.specs[j];
                if (spec.name === 'Announced') {
                    return spec.value;
                }
            }
        }
    }
}