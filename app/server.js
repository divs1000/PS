// server.js
const express  = require('express');
const mongoose = require('mongoose');
const path     = require('path');
const cors     = require('cors');

const app = express();
app.use(cors());
app.use(express.json());

// 1) Connect to MongoDB
mongoose.connect('mongodb://127.0.0.1:27017/frequency_db', {
  useNewUrlParser:    true,
  useUnifiedTopology: true
})
.then(() => console.log('MongoDB connected'))
.catch(err => console.error('MongoDB connection error:', err));

// 2) Define schema & model
const freqSchema = new mongoose.Schema({
  time:      Number,
  frequency: Number
}, { collection: 'time_vs_frequency' });

const Freq = mongoose.model('Freq', freqSchema);

// 3) Serve the frontend
app.use(express.static(path.join(__dirname, 'public')));

// 4) API endpoint to fetch the latest N points
app.get('/api/freq', async (req, res) => {
  const limit = parseInt(req.query.limit) || 200;
  const docs  = await Freq.find()
                          .sort({ time: 1 })
                          .limit(limit);
  res.json(docs);
});

// 5) Start server
const PORT = process.env.PORT || 4000;
app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});

