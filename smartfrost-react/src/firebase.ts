import { initializeApp, type FirebaseApp } from "firebase/app";
import { getAuth, type Auth } from "firebase/auth";
import { getDatabase, type Database } from "firebase/database";
import { getStorage, type FirebaseStorage } from "firebase/storage";

// SmartFrost Firebase Web Configuration
// Must match android/app/google-services.json (project: frost-score).
// NOTE: appId below is a placeholder for the Web app; replace it with the real
// Web App ID from Firebase Console > Project settings > Your apps (Web).
// It is not required for Realtime Database / Auth to work.
export const firebaseConfig = {
  apiKey: "AIzaSyBQkp792yzJm4IF78E5RXab59J0lA5iLRI",
  authDomain: "frost-score.firebaseapp.com",
  projectId: "frost-score",
  databaseURL: "https://frost-score-default-rtdb.asia-southeast1.firebasedatabase.app",
  storageBucket: "frost-score.firebasestorage.app",
  messagingSenderId: "144256451538",
  appId: "1:144256451538:web:smartfrost_web"
};

// Initialize Firebase App
export const app: FirebaseApp = initializeApp(firebaseConfig);

// Initialize Firebase Services (data lives in Realtime Database, same as the mobile app)
export const auth: Auth = getAuth(app);
export const rtdb: Database = getDatabase(app);
export const storage: FirebaseStorage = getStorage(app);

export default app;
