import mongoose from "mongoose";

const reportSchema = new mongoose.Schema({
  asset: { type: mongoose.Schema.Types.ObjectId, ref: "Asset", required: true },
  reportedBy: { type: mongoose.Schema.Types.ObjectId, ref: "User", required: true },
  date: { type: Date, default: Date.now },
  issue: { type: String, required: true },
  status: { type: String, default: "Open" },   // Open, In Progress, Resolved
});

export default mongoose.model("Report", reportSchema);
