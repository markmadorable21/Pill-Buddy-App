const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

exports.linkCaregiver = functions.https.onCall(async (data, context) => {
  // Optional: verify caller is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError(
        "unauthenticated",
        "Request had no auth.",
    );
  }

  const caregiverEmail = data.email;
  const patientUid = context.auth.uid;

  if (!caregiverEmail) {
    throw new functions.https.HttpsError(
        "invalid-argument",
        "Missing caregiver email.",
    );
  }

  try {
    const userRecord = await admin.auth().getUserByEmail(caregiverEmail);
    const caregiverUid = userRecord.uid;

    // Update patient document with caregiver UID
    await admin.firestore().collection("users").doc(patientUid).update({
      caregiverUid: caregiverUid,
    });

    return {success: true, caregiverUid};
  } catch (error) {
    console.error("Error linking caregiver:", error);
    throw new functions.https.HttpsError("not-found", "Caregiver not found.");
  }
});
