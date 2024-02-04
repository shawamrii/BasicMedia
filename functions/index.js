const functions = require('firebase-functions');
const sgMail = require('@sendgrid/mail');

sgMail.setApiKey('YOUR_SENDGRID_API_KEY');

exports.sendEmail = functions.https.onRequest((req, res) => {
  if (req.method !== 'POST') {
    return res.status(403).send('Forbidden!');
  }

  const { to, subject, text } = req.body;

  const msg = {
    to,
    from: 'your-email@example.com',
    subject,
    text,
  };

  sgMail.send(msg)
    .then(() => res.status(200).send('Email sent successfully!'))
    .catch((error) => res.status(400).send(`Error sending email: ${error}`));
});
