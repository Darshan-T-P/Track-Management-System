import mongoose from 'mongoose';

const vendorSchema = new mongoose.Schema({
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
  bankDetails: {
    bankName: String,
    accountNumber: String,
    ifscCode: String,
    accountType: String
  },
  website: String,
  rating: { type: Number, default: 0 },
  licenseNumber: String,
  licenseExpiryDate: Date,
  gstin: String,
  pannumber: String,
  status: { type: String, enum: ["active", "blacklisted", "pending"], default: "pending" },
  createdAt: { type: Date, default: Date.now },
  isVerified: { type: Boolean, default: false },
});


export default mongoose.model('Vendor', vendorSchema);

