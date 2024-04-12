import { initializeApp } from "firebase/app";
import { getAnalytics, logEvent } from "firebase/analytics";

interface firebaseConfig{
    apiKey:string;
    authDomain: string;
    projectId: string;
    storageBucket: string;
    messagingSenderId: string;
    appId: string;
    measurementId: string;
}

const logFirebaseAnalytic = (_firebaseConfig:firebaseConfig,eventName:string)=>{
    const app = initializeApp(_firebaseConfig);
    const analytics = getAnalytics(app);
    logEvent(analytics,eventName);
}

export default {
    logFirebaseAnalytic
}