// models/Batch.js
import mongoose from "mongoose";

const batchSchema = new mongoose.Schema({
  batchNumber: { type: String, required: true, unique: true },
  manufacturerId: { type: mongoose.Schema.Types.ObjectId, ref: "Manufacturer", required: true },
  vendorId: { type: mongoose.Schema.Types.ObjectId, ref: "Vendor", required: true },
  productionDate: { type: Date, required: true },
  expiryDate: { type: Date },
}, { timestamps: true });

batchSchema.virtual('products', {
  ref: 'Product',
  localField: '_id',
  foreignField: 'batchId'
});
batchSchema.set('toObject', { virtuals: true });
batchSchema.set('toJSON', { virtuals: true });

export default mongoose.model("Batch", batchSchema);
