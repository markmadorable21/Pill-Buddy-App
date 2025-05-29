// backend/sendEmail.js

const sgMail = require('@sendgrid/mail');
sgMail.setApiKey(process.env.SENDGRID_API_KEY);

async function sendVerificationEmail(toEmail, verificationCode) {
  const msg = {
    to: toEmail,
    from: 'pillbuddy.madorable@gmail.com', // must be verified sender in SendGrid
    subject: 'Email Verification',
    text: `Your verification code is: ${verificationCode}`,
  };

  try {
    await sgMail.send(msg);
    console.log('Email sent successfully');
  } catch (error) {
    console.error(error);
  }
}

// Example usage
sendVerificationEmail('markazjudaya@gmail.com', '123456');
