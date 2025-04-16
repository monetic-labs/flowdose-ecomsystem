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

// Publishable API key endpoint needed by the frontend
app.get('/store/publishable-api-keys', (req, res) => {
  res.json({
    publishable_api_keys: [
      {
        id: "pk_test_medusa_dummy_key",
        created_at: new Date().toISOString(),
        revoked_at: null
      }
    ]
  });
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