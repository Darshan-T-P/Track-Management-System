import mongoose from "mongoose";

const assetSchema = new mongoose.Schema({
  qrCode: { type: String, unique: true, required: true },
  name: { type: String, required: true },
  category: String,
  status: { type: String, enum: ["available", "in_use", "maintenance"], default: "available" },
  location: String,
  installedOn: { type: Date, default: Date.now },
  warrantyEndsOn: { type: Date, default: Date.now },
  expectedLifeYears: { type: Number, default: 5 },
  specifications: { type: Object, default: {} },
  manufacturer: { type: String, default: "" },
  batchNumber: { type: String, default: "" },
  manufacturingDate: { type: Date, default: Date.now },
  installationDate: { type: Date, default: Date.now },


  lastUpdated: { type: Date, default: Date.now },
  history: [
    {
      action: String,
      userId: { type: mongoose.Schema.Types.ObjectId, ref: "User" },
      timestamp: { type: Date, default: Date.now },
    }
  ]
});

export default mongoose.model("Asset", assetSchema);
