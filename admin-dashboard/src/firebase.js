import { initializeApp } from 'firebase/app';
import { getAuth } from 'firebase/auth';
import { getFirestore } from 'firebase/firestore';

// Your Firebase config from the Firebase Console
const firebaseConfig = {
    apiKey: "AIzaSyDj1DXsO4ymW4ayBE9QWTlJR4rCInTcFQo",
    authDomain: "shopngo-76b87.firebaseapp.com",
    projectId: "shopngo-76b87",
    storageBucket: "shopngo-76b87.firebasestorage.app",
    messagingSenderId: "770391979558",
    appId: "1:770391979558:web:fc1b5a28d75998e50158e7",
    measurementId: "G-QC9DH1ZJLF"
  };
// Initialize Firebase
const app = initializeApp(firebaseConfig);
export const auth = getAuth(app);
export const db = getFirestore(app);