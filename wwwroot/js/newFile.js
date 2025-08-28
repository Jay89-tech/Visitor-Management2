// wwwroot/js/firebase-config.js

// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
import { getAnalytics } from "firebase/analytics";
import { getAuth, onAuthStateChanged } from "firebase/auth";
import { getFirestore } from "firebase/firestore";

// Firebase configuration - replace with your actual config
const firebaseConfig = {
    apiKey: "AIzaSyCV6aOftBK9vKud_elM_mj2GICUW6eO8ls",
    authDomain: "testing-827ee.firebaseapp.com",
    projectId: "testing-827ee",
    storageBucket: "testing-827ee.firebasestorage.app",
    messagingSenderId: "58927123029",
    appId: "1:58927123029:web:fe9f166ba1cb2ed35762dc",
    measurementId: "G-QFEJFXN2HQ"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const analytics = getAnalytics(app);

// Initialize Firebase services using the app instance
const auth = getAuth(app);
const db = getFirestore(app);

// Auth state observer
onAuthStateChanged(auth, (user) => {
    if (user) {
        console.log('User is signed in:', user.email);
        // Redirect to dashboard if not on auth pages
        if (window.location.pathname.includes('/Account/')) {
            window.location.href = '/Dashboard';
        }
    } else {
        console.log('User is signed out');
        // Redirect to login if not on auth pages
        if (!window.location.pathname.includes('/Account/')) {
            window.location.href = '/Account/Login';
        }
    }
});