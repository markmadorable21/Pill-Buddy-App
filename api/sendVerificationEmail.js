// api/sendVerificationEmail.js
import sgMail from '@sendgrid/mail';

sgMail.setApiKey(process.env.SENDGRID_API_KEY);

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const { email, verificationLink } = req.body;

  if (!email || !verificationLink) {
    return res
      .status(400)
      .json({ error: 'Email and verification link required' });
  }

  const msg = {
    to: email,
    from: 'your_verified_sendgrid_email@example.com', // Verified sender in SendGrid
    subject: 'Confirm Your Email Address',
    text: `Please confirm your email by clicking the following link: ${verificationLink}`,
    html: `<p>Please confirm your email by clicking the following link:</p><a href="${verificationLink}">Confirm Email</a>`,
  };

  try {
    await sgMail.send(msg);
    return res.status(200).json({ message: 'Verification email sent' });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ error: 'Failed to send email' });
  }
}
