const functions = require("firebase-functions");
const sgMail = require("@sendgrid/mail");

// Set your SendGrid API key as an environment variable in Firebase
sgMail.setApiKey(functions.config().sendgrid.key);

exports.sendEmail = functions.https.onRequest(async (req, res) => {
  // Allow only POST method
  if (req.method !== "POST") {
    return res.status(405).send("Method Not Allowed");
  }

  const {to, subject, text} = req.body;

  if (!to || !subject || !text) {
    return res.status(400).send("Missing parameters");
  }

  const msg = {
    to,
    from: "pillbuddy.madorable@gmail.com",
    subject,
    text,
  };

  try {
    await sgMail.send(msg);
    return res.status(200).send("Email sent successfully");
  } catch (error) {
    console.error("Error sending email:", error);
    return res.status(500).send("Failed to send email");
  }
});
