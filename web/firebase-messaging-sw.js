importScripts("https://www.gstatic.com/firebasejs/10.12.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.12.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyBLHdr7R_hhUWvEzn2mKMOhCtCy1px6IeU",
  authDomain: "aydindabutaksi.firebaseapp.com",
  projectId: "aydindabutaksi",
  storageBucket: "aydindabutaksi.firebasestorage.app",
  messagingSenderId: "697181183608",
  appId: "1:697181183608:web:2efed7a4a0332bce88578d",
  measurementId: "G-GRGW5YD7NE"
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((message) => {
  console.log("[firebase-messaging-sw.js] Background message:", message);
});
