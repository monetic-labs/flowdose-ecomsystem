#!/usr/bin/env node

const { createMedusaApp } = require('@medusajs/medusa');
require('dotenv').config();

/**
 * Script to create a test admin invitation for testing purposes
 * 
 * Usage: node create-invite.js <email_address>
 * Example: node create-invite.js newadmin@example.com
 */

async function createInvite(email) {
  // Initialize the Medusa app
  const { container } = await createMedusaApp();
  
  try {
    // Get the user module
    const userService = container.resolve("userService");
    
    // Create the invite
    const invite = await userService.create({
      email,
      role: 'admin',
    });
    
    console.log(`✅ Successfully created invite for ${email}`);
    console.log(`The invite token is: ${invite.token}`);
    console.log(`An email should be sent with the invitation.`);
    
    return invite;
  } catch (error) {
    console.error(`❌ Failed to create invite for ${email}:`);
    console.error(error);
    process.exit(1);
  }
}

// Main function
(async () => {
  const email = process.argv[2];
  
  if (!email) {
    console.error('❌ Please provide an email address as an argument');
    console.error('Usage: node create-invite.js newadmin@example.com');
    process.exit(1);
  }
  
  try {
    await createInvite(email);
    process.exit(0);
  } catch (error) {
    console.error('❌ An unexpected error occurred:');
    console.error(error);
    process.exit(1);
  }
})(); 