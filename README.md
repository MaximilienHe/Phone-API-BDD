# Phone Scripting Saving

Phone Scripting Saving est une application Node.js qui permet de récupérer et de stocker les données d'un catalogue de téléphones à partir d'une API distante. Les données sont stockées dans une base de données MySQL et sont mises à jour régulièrement grâce à un cron job.


## Prérequis

Avant de commencer, assurez-vous d'avoir installé les éléments suivants sur votre machine :

- Node.js
- npm
- MySQL


## Installation

- Clonez le projet sur votre machine
- Dans le dossier du projet, installez les dépendances en exécutant la commande suivante :
```bash
npm install
```
- Renommez le fichier .env.example en .env et modifiez les valeurs pour correspondre à votre configuration de base de données.


## Utilisation
### Initialisation de la base de données

Pour initialiser la base de données avec les données de l'API distante, il suffit de décommenter la ligne suivante dans le fichier app.js :
```js
// fetchAndSave(connection);
```

Puis lancez l'application en exécutant la commande suivante :

```bash
npm run start
```

### Mise à jour de la base de données

Pour mettre à jour la base de données avec les nouvelles données de l'API distante, il suffit de décommenter la ligne suivante dans le fichier app.js :

```js
// addCron(connection);
```

Puis lancez l'application en exécutant la commande suivante :

```bash
npm run start
```

Un cron job sera lancé toutes les 24 heures pour récupérer les nouvelles données de l'API et les stocker dans la base de données.

## Développement

Le projet est structuré de la manière suivante :

- app.js : le point d'entrée de l'application qui initialise la connexion à la base de données et lance les fonctions fetchAndSave() ou addCron() en fonction du besoin.
- fetch-and-save.js : le script qui permet de récupérer les données de l'API distante et de les stocker dans la base de données.
- addCron.js : le script qui permet de récupérer les nouvelles données de l'API distante et de les ajouter à la base de données.
