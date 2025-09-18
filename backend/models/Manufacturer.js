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
    bankDetails: {
        bankName: String,
    },
    licenseNo: String,
    status: { type: String, enum: ["approved", "pending", "revoked"], default: "pending" },
    createdAt: { type: Date, default: Date.now }
  });
  
  export default mongoose.model("Manufacturer", manufacturerSchema);