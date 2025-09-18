const mongoose = require('mongoose');

const zoneSchema = new mongoose.Schema({
  name: { type: String, required: true },
  code: { type: String, unique: true },
  description: { type: String },
  status: { type: String, default: 'active' },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});

module.exports = mongoose.model('Zone', zoneSchema);
