const admin = require('firebase-admin');
const fs = require('fs');

// Initialize Firebase Admin SDK
// For production, use service account key
admin.initializeApp({
  credential: admin.credential.cert('./serviceAccountKey.json'),
  projectId: 'ipucuavcisiapp'
});

// For emulator, use:
// admin.initializeApp({
//   projectId: 'ipucuavcisiapp'
// });

// If using emulator, set the emulator host
// if (process.env.FIRESTORE_EMULATOR_HOST) {
//   admin.firestore().settings({
//     host: process.env.FIRESTORE_EMULATOR_HOST,
//     ssl: false
//   });
// }

const db = admin.firestore();

async function importData() {
  try {
    const data = JSON.parse(fs.readFileSync('oyun_verileri.json', 'utf8'));

    for (const [collectionName, documents] of Object.entries(data)) {
      console.log(`Importing collection: ${collectionName}`);
      for (const [docId, docData] of Object.entries(documents)) {
        await db.collection(collectionName).doc(docId).set(docData);
        console.log(`Imported document: ${collectionName}/${docId}`);
      }
    }

    console.log('Data import completed successfully!');
  } catch (error) {
    console.error('Error importing data:', error);
  } finally {
    admin.app().delete();
  }
}

importData();