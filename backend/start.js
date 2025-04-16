const express = require('express');
const cors = require('cors');
const app = express();
const port = process.env.PORT || 9000;

// Enable CORS
app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// Key exchange endpoint for testing connection
app.get('/key-exchange', (req, res) => {
  res.json({ success: true, message: 'Backend connection successful' });
});

// Medusa store API route for getting publishable API key
app.get('/store/publishable-api-keys', (req, res) => {
  // Format required by the Medusa storefront
  const publishable_key = {
    id: "pk_test_1234567890",
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
    created_by: "admin",
    revoked_by: null,
    revoked_at: null,
    title: "Storefront API Key"
  };
  
  res.json({
    publishable_api_keys: [publishable_key]
  });
});

// Medusa store API to use in header request patterns
app.get('/store/publishable-api-key', (req, res) => {
  res.json({
    publishable_api_key: {
      id: "pk_test_1234567890",
      created_at: new Date().toISOString(), 
      updated_at: new Date().toISOString(),
      created_by: "admin",
      revoked_by: null,
      revoked_at: null,
      title: "Storefront API Key"
    }
  });
});

// Medusa admin products endpoint (for testing DB connection)
app.get('/admin/products', (req, res) => {
  res.json({ success: true, products: [] });
});

// Catch-all for debugging
app.use('*', (req, res) => {
  console.log(`Request received: ${req.method} ${req.originalUrl}`);
  res.status(404).json({ message: 'Endpoint not implemented yet', path: req.originalUrl });
});

// Start the server
app.listen(port, '0.0.0.0', () => {
  console.log(`Backend server running on port ${port}`);
}); 