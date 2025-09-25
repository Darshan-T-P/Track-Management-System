import mongoose from "mongoose";

const stationSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    code: { type: String, required: true, unique: true }, // e.g., SBC, MAS
    divisionId: { type: mongoose.Schema.Types.ObjectId, ref: "Division", required: true },
    zoneId: { type: mongoose.Schema.Types.ObjectId, ref: "Zone", required: true },
    location: {
      lat: Number,
      lng: Number,
    },
  },
  { timestamps: true }
);

export default mongoose.model("Station", stationSchema);
