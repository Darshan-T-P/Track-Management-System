import mongoose from "mongoose";

const inspectionSchema = new mongoose.Schema({
  date: { type: Date, required: true },
  inspector: { type: String, required: true }, // later can be ref to User
  remarks: String,
  status: { type: String, enum: ["Passed", "Failed", "Pending"], required: true },
}, { _id: false });

const reviewSchema = new mongoose.Schema({
  reviewer: { type: String, required: true }, // later can be ref to User
  date: { type: Date, default: Date.now },
  feedback: String,
  rating: { type: Number, min: 1, max: 5 },
  image: String,
}, { _id: false });

const productSchema = new mongoose.Schema(
  {
    uuid: { type: String, unique: true, required: true }, // QR code links to this
    productName: { type: String, required: true },
    itemType: { type: String, enum: ["Clip", "Pad", "Liner", "Sleeper"], required: true },
    lotNumber: { type: String, required: true },
    batchId: { type: mongoose.Schema.Types.ObjectId, ref: "Batch" },
    tmsLotReference: { type: String },

    // Manufacturer
    manufacturerId: { type: mongoose.Schema.Types.ObjectId, ref: "Manufacturer", required: true },
    dateOfManufacture: { type: Date, required: true },

    // Vendor
    vendorId: { type: mongoose.Schema.Types.ObjectId, ref: "Vendor", required: true },
    dateOfSupply: { type: Date, required: true },

    // Warranty
    warrantyStartDate: { type: Date },
    warrantyEndDate: { type: Date },

    // Installation
    installationDate: { type: Date },
    installationLocation: { type: String },
    stationId: { type: mongoose.Schema.Types.ObjectId, ref: "Station" },
    installedBy: { type: String }, // could link to User

    // Inspections
    inspections: [inspectionSchema],
    lastInspectionDate: { type: Date },

    // Reviews
    reviews: [reviewSchema],

    // Extra
    description: String,
    category: String,
    serialNumber: String,

    // System fields
    qrCodeUrl: { type: String }, // path to stored QR
    detailsEntered: { type: Boolean, default: false },
  },
  { timestamps: true }
);

export default mongoose.model("Product", productSchema);
