const { onCall, HttpsError } = require("firebase-functions/v2/https");
const { getFirestore } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");
const { initializeApp } = require("firebase-admin/app");

initializeApp();

// Authenticated clients may ask the backend to notify only themselves. Never expose Admin credentials to iOS.
exports.sendHighEnergyPush = onCall(async (request) => {
  if (!request.auth) throw new HttpsError("unauthenticated", "Sign in is required.");
  const { currentPowerWatts, thresholdWatts, sourceToken } = request.data || {};
  if (!Number.isFinite(currentPowerWatts) || !Number.isFinite(thresholdWatts) || currentPowerWatts <= thresholdWatts) {
    throw new HttpsError("invalid-argument", "A valid threshold crossing is required.");
  }
  const tokens = await getFirestore().collection("users").doc(request.auth.uid).collection("fcmTokens").get();
  const registrationTokens = tokens.docs
    .filter((doc) => doc.id !== sourceToken && doc.data().highEnergyAlertsEnabled !== false)
    .map((doc) => doc.id);
  if (!registrationTokens.length) return { sent: 0 };
  const result = await getMessaging().sendEachForMulticast({
    tokens: registrationTokens,
    notification: { title: "High Energy Usage Detected", body: `Simulated power is ${Math.round(currentPowerWatts)} W (threshold ${Math.round(thresholdWatts)} W).` },
    data: { type: "highEnergy", destination: "dashboard" }
  });
  return { sent: result.successCount };
});
