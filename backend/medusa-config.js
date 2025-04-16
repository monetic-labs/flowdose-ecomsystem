// This file is a wrapper to ensure compatibility with both ES modules and CommonJS
import { createRequire } from 'module';
const require = createRequire(import.meta.url);

const config = require('./medusa-config.cjs');
export default config;
