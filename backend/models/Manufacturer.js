import mongoose from 'mongoose';

const manufacturerSchema = new mongoose.Schema({
  name: { type: String, required: true },
  contactPerson: String,
  phone: String,
  email: String,
  address: {
    street: String,
    city: String,
    state: String,
    country: String,
    pincode: String
  },
  licenseNumber: String,
  licenseExpiryDate: Date,
  gstin: String,
  pannumber: String,
  website: String,
  rating: { type: Number, default: 0 },
  status: { type: String, enum: ["active", "blacklisted", "pending"], default: "pending" },
  createdAt: { type: Date, default: Date.now },
  isVerified: { type: Boolean, default: false },
});

export default mongoose.model("Manufacturer", manufacturerSchema);