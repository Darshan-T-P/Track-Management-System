import mongoose from "mongoose";

const userSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    email: { type: String, unique: true, required: true },
    phone: { type: String },
    passwordHash: { type: String },
    authProvider: { type: String, default: "local" },

    role: {
      type: String,
      enum: [
        "super_admin",
        "zone_admin",
        "division_admin",
        "station_supervisor",
        "inspector",
        "vendor",
        "manufacturer",
      ],
      required: true,
    },

    zoneId: { type: mongoose.Schema.Types.ObjectId, ref: "Zone" },
    divisionId: { type: mongoose.Schema.Types.ObjectId, ref: "Division" },
    stationId: { type: mongoose.Schema.Types.ObjectId, ref: "Station" },
    vendorId: { type: mongoose.Schema.Types.ObjectId, ref: "Vendor" },
    manufacturerId: { type: mongoose.Schema.Types.ObjectId, ref: "Manufacturer" },

    permissions: [String],
    status: { type: String, enum: ["active", "inactive"], default: "active" },
    lastLogin: { type: Date },
    createdBy: { type: mongoose.Schema.Types.ObjectId, ref: "User" },

    profilePicUrl: { type: String },
    designation: { type: String },
    department: { type: String },

    location: {
      lat: { type: Number },
      lng: { type: Number },
    },

    deviceId: { type: String },
  },
  { timestamps: true }
);

export default mongoose.model("User", userSchema);
