import mongoose from "mongoose";

const zoneSchema = new mongoose.Schema(
  {
    name: { type: String, required: true, unique: true },
    code: { type: String, required: true, unique: true }, // e.g., SR, NR
    headquarters: { type: String },
  },
  { timestamps: true }
);

export default mongoose.model("Zone", zoneSchema);
