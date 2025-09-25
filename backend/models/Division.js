import mongoose from "mongoose";

const divisionSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    code: { type: String, required: true },
    zoneId: { type: mongoose.Schema.Types.ObjectId, ref: "Zone", required: true },
    headquarters: { type: String },
  },
  { timestamps: true }
);

export default mongoose.model("Division", divisionSchema);
