// Creates the first admin from ADMIN_EMAIL / ADMIN_PASSWORD, through the app's
// own seeding helper, and marks the installation as completed. It does
// nothing once any user exists, so later deploys never touch your accounts.
// Replaces upstream's `db:seed:user`, which creates the published
// user@automatisch.io / sample login.
import process from 'process';
import { createUser } from './bin/database/utils.js';

const email = (process.env.ADMIN_EMAIL || '').trim();
const password = process.env.ADMIN_PASSWORD || '';

if (!email || password.length < 6) {
  console.error(
    '[railway] ADMIN_EMAIL and ADMIN_PASSWORD (6+ characters) must be set on this service.'
  );
  process.exit(1);
}

createUser(email, password);
