import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

// Initialize Firebase Admin
admin.initializeApp();

// Basic health check function
export const healthCheck = functions.https.onCall(async (data, context) => {
    return {
        status: 'healthy',
        timestamp: new Date().toISOString(),
        message: 'E-Agriculture System is running'
    };
});