import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import { messaging } from 'firebase-admin';

var serviceAccount = require('../service-account.json');

admin.initializeApp({
	credential: admin.credential.cert(serviceAccount),
	databaseURL: 'https://gifthub-1c81c.firebaseio.com'
});

export const sendBroadcastNotification = functions.https
	.onRequest(async (req, res) => {
		if (req.method !== 'POST') {
			// Handle only POST requests
			return;
		}
		const title = req.body.title;
		const body = req.body.message;
		const tokens = req.body.tokens;
		const message = {
			notification: {
				title: title,
				body: body
			},
			tokens: tokens
		} as messaging.MulticastMessage;

		// Send a message to devices subscribed to the provided topic.
		try {
			const response = await admin.messaging().sendMulticast(message);
			// Response is a message ID string.
			console.log('Successfully sent message:', response);
			res.status(200).json(response);
		} catch (error) {
			console.log('Error sending message:', error);
			res.status(500).json({
				error: error
			});
		}
	});