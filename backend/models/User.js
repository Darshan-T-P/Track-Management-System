import mongoose from 'mongoose';

const userSchema = new mongoose.Schema({
  name: { type: String, required: true },
  email: { type: String, unique: true, required: true },
  phone: { type: String },
  passwordHash: { type: String },
  salt: { type: String },
  authProvider: { type: String, default: 'local' },
  role: { 
    type: String, 
    enum: ['super_admin', 'zone_admin', 'division_admin', 'station_supervisor', 'inspector','vendor','manufacturer'], 
    required: true 
  },
  zoneId: { type: mongoose.Schema.Types.ObjectId, ref: 'Zone' },
  divisionId: { type: mongoose.Schema.Types.ObjectId, ref: 'Division' },
  stationId: { type: mongoose.Schema.Types.ObjectId, ref: 'Station' },
  vendorId: { type: mongoose.Schema.Types.ObjectId, ref: 'Vendor' },
  permissions: [String],
  status: { type: String, default: 'active' },
  lastLogin: { type: Date },
  createdBy: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  profilePic: { type: Buffer },
  // employeeCode: { type: String, unique: true,sparse: true},
  designation: { type: String },
  department: { type: String },
  location: {
    lat: Number,
    lng: Number
  },
  deviceId: String,
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now }
});

export default mongoose.model('User', userSchema);
