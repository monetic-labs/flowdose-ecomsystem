#!/usr/bin/env node

const { Resend } = require('resend');
require('dotenv').config();

const apiKey = process.env.RESEND_API_KEY;
const fromEmail = process.env.RESEND_FROM || process.env.RESEND_FROM_EMAIL;

if (!apiKey) {
  console.error('Error: RESEND_API_KEY is not set in the environment variables');
  process.exit(1);
}

if (!fromEmail) {
  console.error('Error: RESEND_FROM or RESEND_FROM_EMAIL is not set in the environment variables');
  process.exit(1);
}

const testEmail = process.argv[2];
if (!testEmail) {
  console.error('Error: Please provide a test email address as an argument');
  console.error('Usage: node verify-resend.js test@example.com');
  process.exit(1);
}

async function main() {
  try {
    const resend = new Resend(apiKey);
    
    console.log(`Sending test email from ${fromEmail} to ${testEmail}...`);
    
    const result = await resend.emails.send({
      from: fromEmail,
      to: testEmail,
      subject: 'Flowdose Email Verification Test',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <h2 style="color: #5E35B1;">Flowdose Email Verification</h2>
          <p>This is a test email to verify that your Resend setup is working correctly with the flowdose.xyz domain.</p>
          <p>If you received this email, your Resend configuration is correctly set up!</p>
          <hr style="border: 1px solid #eaeaea; margin: 20px 0;" />
          <p style="color: #666; font-size: 12px;">This is an automated message from Flowdose.</p>
        </div>
      `,
    });
    
    console.log('Email sent successfully!');
    console.log('Response:', result);
  } catch (error) {
    console.error('Error sending email:');
    console.error(error);
    process.exit(1);
  }
}

main(); 