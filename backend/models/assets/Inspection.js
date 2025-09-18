import mongoose from "mongoose";

const inspectionSchema = new mongoose.Schema({
  asset: { type: mongoose.Schema.Types.ObjectId, ref: "Asset", required: true },
  inspector: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  date: { type: Date, default: Date.now },
  condition: { type: String, required: true },     // Good, Needs Repair, Faulty
  remarks: { type: String },
});

export default mongoose.model("Inspection", inspectionSchema);
