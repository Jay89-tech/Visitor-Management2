// wwwroot/js/site.js

// Make sure to import the necessary Firebase services from firebase-config.js
import { auth, db } from './firebase-config.js';
import { signInWithEmailAndPassword, createUserWithEmailAndPassword, sendPasswordResetEmail } from 'firebase/auth';
import { collection, doc, setDoc } from 'firebase/firestore';
import { serverTimestamp } from 'firebase/firestore';

// Login functionality
document.addEventListener('DOMContentLoaded', function () {
    // Login form
    const loginForm = document.getElementById('loginForm');
    if (loginForm) {
        loginForm.addEventListener('submit', handleLogin);
    }

    // Register form
    const registerForm = document.getElementById('registerForm');
    if (registerForm) {
        registerForm.addEventListener('submit', handleRegister);
    }

    // Forgot password form
    const forgotPasswordForm = document.getElementById('forgotPasswordForm');
    if (forgotPasswordForm) {
        forgotPasswordForm.addEventListener('submit', handleForgotPassword);
    }
});

async function handleLogin(e) {
    e.preventDefault();

    const email = document.getElementById('email').value;
    const password = document.getElementById('password').value;
    const loginBtn = document.getElementById('loginBtn');
    const errorMessage = document.getElementById('error-message');

    // Show loading state
    showLoading(loginBtn);
    hideMessage(errorMessage);

    try {
        const userCredential = await signInWithEmailAndPassword(auth, email, password);
        console.log('Login successful:', userCredential.user.email);
        window.location.href = '/Dashboard';
    } catch (error) {
        console.error('Login error:', error);
        showError(errorMessage, getFirebaseErrorMessage(error.code));
    } finally {
        hideLoading(loginBtn);
    }
}

async function handleRegister(e) {
    e.preventDefault();

    const firstName = document.getElementById('firstName').value;
    const lastName = document.getElementById('lastName').value;
    const email = document.getElementById('email').value;
    const employeeId = document.getElementById('employeeId').value;
    const department = document.getElementById('department').value;
    const password = document.getElementById('password').value;
    const confirmPassword = document.getElementById('confirmPassword').value;
    const registerBtn = document.getElementById('registerBtn');
    const errorMessage = document.getElementById('error-message');

    // Validation
    if (password !== confirmPassword) {
        showError(errorMessage, 'Passwords do not match');
        return;
    }

    if (password.length < 6) {
        showError(errorMessage, 'Password must be at least 6 characters');
        return;
    }

    // Show loading state
    showLoading(registerBtn);
    hideMessage(errorMessage);

    try {
        // Create user account
        const userCredential = await createUserWithEmailAndPassword(auth, email, password);

        // Save additional user data to Firestore
        const userDocRef = doc(db, 'users', userCredential.user.uid);
        await setDoc(userDocRef, {
            firstName: firstName,
            lastName: lastName,
            email: email,
            employeeId: employeeId,
            department: department,
            createdAt: serverTimestamp(),
            role: 'employee'
        });

        console.log('Registration successful:', userCredential.user.email);
        window.location.href = '/Dashboard';
    } catch (error) {
        console.error('Registration error:', error);
        showError(errorMessage, getFirebaseErrorMessage(error.code));
    } finally {
        hideLoading(registerBtn);
    }
}

async function handleForgotPassword(e) {
    e.preventDefault();

    const email = document.getElementById('email').value;
    const resetBtn = document.getElementById('resetBtn');
    const errorMessage = document.getElementById('error-message');
    const successMessage = document.getElementById('success-message');

    // Show loading state
    showLoading(resetBtn);
    hideMessage(errorMessage);
    hideMessage(successMessage);

    try {
        await sendPasswordResetEmail(auth, email);
        showSuccess(successMessage, 'Password reset email sent! Check your inbox.');
    } catch (error) {
        console.error('Password reset error:', error);
        showError(errorMessage, getFirebaseErrorMessage(error.code));
    } finally {
        hideLoading(resetBtn);
    }
}

// Utility functions
function showLoading(button) {
    button.disabled = true;
    button.querySelector('.btn-text').style.display = 'none';
    button.querySelector('.btn-loader').style.display = 'block';
}

function hideLoading(button) {
    button.disabled = false;
    button.querySelector('.btn-text').style.display = 'block';
    button.querySelector('.btn-loader').style.display = 'none';
}

function showError(element, message) {
    element.textContent = message;
    element.style.display = 'block';
}

function showSuccess(element, message) {
    element.textContent = message;
    element.style.display = 'block';
}

function hideMessage(element) {
    element.style.display = 'none';
}

function getFirebaseErrorMessage(errorCode) {
    const errorMessages = {
        'auth/user-not-found': 'No account found with this email address.',
        'auth/wrong-password': 'Invalid password.',
        'auth/email-already-in-use': 'An account already exists with this email address.',
        'auth/invalid-email': 'Please enter a valid email address.',
        'auth/weak-password': 'Password should be at least 6 characters.',
        'auth/too-many-requests': 'Too many failed attempts. Please try again later.',
    };

    return errorMessages[errorCode] || 'An error occurred. Please try again.';
}