import sendgrid from '@sendgrid/mail';

sendgrid.setApiKey(process.env.SENDGRID_API_KEY);

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  const { to, subject, text } = req.body;

  if (!to || !subject || !text) {
    return res.status(400).json({ error: 'Missing fields in request body' });
  }

  try {
    await sendgrid.send({
      to,
      from: 'markazjudayae@gmail.com', // <-- Replace with your verified sender email
      subject,
      text,
    });
    res.status(200).json({ message: 'Email sent successfully' });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: 'Error sending email' });
  }
}
