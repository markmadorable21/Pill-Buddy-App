const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

admin.initializeApp();

// Configure your email transporter (example with Gmail)
const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "pillbuddy.madorable@gmail.com", // Your email here
    pass: "ypzi pruq swhy fbkq", // App password (not your main password)
  },
});

// Generate the confirmation URL with patientId as query param
const getConfirmationUrl = (patientId) => {
  const baseUrl = "https://pill-buddy-cpe-nnovators.web.app"; // Your app's URL that will handle confirmation
  return `${baseUrl}?patientId=${patientId}`;
};

// Cloud Function to send confirmation email
exports.sendConfirmationEmail = functions.https.onRequest(async (req, res) => {
  try {
    const {email, patientId} = req.body;

    if (!email || !patientId) {
      return res.status(400).send("Missing email or patientId");
    }

    const confirmationUrl = getConfirmationUrl(patientId);

    const mailOptions = {
      from: "PillBuddy <pillbuddy.madorable@gmail.com>",
      to: email,
      subject: "Please confirm your email address",
      html: `
        <p>Hello,</p>
        <p>Please confirm your email by clicking the button below:</p>
        <a href="${confirmationUrl}" style="
          display:inline-block;
          padding:10px 20px;
          font-size:16px;
          color:#fff;
          background-color:#007bff;
          text-decoration:none;
          border-radius:5px;
        ">Confirm Email</a>
        <p>If you did not request this, please ignore this email.</p>
      `,
    };

    await transporter.sendMail(mailOptions);

    return res.status(200).send("Confirmation email sent");
  } catch (error) {
    console.error("Error sending confirmation email:", error);
    return res.status(500).send("Internal Server Error");
  }
});
