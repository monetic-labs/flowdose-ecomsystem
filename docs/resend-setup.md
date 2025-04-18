# Resend Setup for Flowdose

This document outlines how to properly set up Resend for email delivery with the flowdose.xyz domain.

## Domain Verification

1. Log in to your [Resend dashboard](https://resend.com/domains)
2. Click on "Add domain"
3. Enter `flowdose.xyz` as the domain
4. Follow the DNS verification steps provided by Resend:
   - Add the TXT records to your DNS configuration for domain verification
   - Add the required MX records (if prompted) for proper email delivery
   - Add the DKIM records for email authentication

DNS records typically look like this:

```
TYPE   | NAME              | VALUE                         | TTL
----------------------------------------------------------------------
TXT    | resend-verification | XXXXXXXXXXXXXXXXXXXXX        | 3600
MX     | @                 | feedback-smtp.us-east-1.amazonses.com | 3600
CNAME  | rs1._domainkey    | rs1.domainkey.xxxxx.resend.com | 3600
CNAME  | rs2._domainkey    | rs2.domainkey.xxxxx.resend.com | 3600
```

5. Wait for DNS propagation (can take up to 24-48 hours, though often much faster)
6. Once verified, update the following environment variables in your production deployment:

```
RESEND_FROM=Flowdose <no-reply@flowdose.xyz>
RESEND_FROM_EMAIL=Flowdose <no-reply@flowdose.xyz>
```

## Testing Email Delivery

To verify that Resend is correctly set up:

1. Run the verification script from the project root directory:

```bash
cd backend
npm run verify-resend your-email@example.com
```

2. Check your inbox for the test email.

## Testing Admin Invitations

To test the admin invitation system:

1. Run the invite creation script:

```bash
cd backend
npm run create-invite new-admin@example.com
```

2. Check the specified email inbox for the invitation email
3. Try clicking the invitation link and completing the signup process

## Troubleshooting

If emails are not being delivered:

1. Check the Resend dashboard for any delivery issues
2. Verify that your domain is properly configured and verified
3. Make sure your environment variables are correctly set
4. Check application logs for any email-related errors

For delivery issues to specific email providers:

1. Gmail/Google Workspace: Check spam folder and ensure SPF/DKIM are properly set up
2. Microsoft (Outlook, Office365): May require additional SPF/DKIM configuration
3. Corporate email systems: May require allowlisting Resend IPs 