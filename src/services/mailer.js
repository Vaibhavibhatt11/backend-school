const nodemailer = require("nodemailer");

const env = require("../config/env");

let transporter = null;

function isMailerConfigured() {
  return Boolean(
    env.SMTP_HOST &&
      env.SMTP_PORT &&
      env.SMTP_USER &&
      env.SMTP_PASS &&
      env.EMAIL_FROM
  );
}

function getTransporter() {
  if (transporter) return transporter;

  transporter = nodemailer.createTransport({
    host: env.SMTP_HOST,
    port: env.SMTP_PORT,
    secure: env.SMTP_SECURE === "true",
    auth: {
      user: env.SMTP_USER,
      pass: env.SMTP_PASS,
    },
  });

  return transporter;
}

async function sendPasswordResetOtpEmail({ to, otp, expiresInMinutes }) {
  if (!isMailerConfigured()) {
    throw new Error("Mailer is not configured");
  }

  const mailer = getTransporter();
  await mailer.sendMail({
    from: env.EMAIL_FROM,
    to,
    subject: "School ERP Password Reset OTP",
    text: `Your password reset OTP is ${otp}. It expires in ${expiresInMinutes} minutes.`,
    html: `
      <div style="font-family:Arial,sans-serif;line-height:1.6;">
        <h2>Password Reset OTP</h2>
        <p>Your OTP is:</p>
        <p style="font-size:24px;font-weight:700;letter-spacing:4px;">${otp}</p>
        <p>This OTP will expire in ${expiresInMinutes} minutes.</p>
        <p>If you did not request this, please ignore this email.</p>
      </div>
    `,
  });
}

module.exports = {
  isMailerConfigured,
  sendPasswordResetOtpEmail,
};
