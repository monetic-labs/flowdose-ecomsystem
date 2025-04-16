const express = require('express');
const app = express();
const port = 9000;

// Basic health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// Key exchange endpoint for storefront
app.get('/key-exchange', (req, res) => {
  res.json({ success: true, message: 'API is running' });
});

// Basic API routes
app.get('/api', (req, res) => {
  res.json({ 
    message: 'Medusa API is coming soon',
    endpoints: [
      { path: '/health', method: 'GET', description: 'Health check endpoint' },
      { path: '/key-exchange', method: 'GET', description: 'Endpoint for storefront to verify backend connectivity' }
    ] 
  });
});

// Start the server
app.listen(port, '0.0.0.0', () => {
  console.log(`Server is running on port ${port}`);
}); 