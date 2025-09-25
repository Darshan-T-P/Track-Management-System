// controllers/batchController.js
import Batch from "../models/Batch.js";
import Product from "../models/Product.js";

// Create a new batch
export const createBatch = async (req, res) => {
  try {
    const { batchNumber, manufacturerId, vendorId, productionDate, expiryDate } = req.body;

    if (!batchNumber || !manufacturerId || !vendorId || !productionDate) {
      return res.status(400).json({ error: "Missing required fields" });
    }

    const batch = new Batch({ batchNumber, manufacturerId, vendorId, productionDate, expiryDate });
    await batch.save();
    res.status(201).json(batch);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
};

// Get all batches
export const getBatches = async (req, res) => {
  try {
    const batches = await Batch.find()
      .populate("manufacturerId", "name")
      .populate("vendorId", "name");
    res.json(batches);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
};

// Get single batch by ID
export const getBatchById = async (req, res) => {
  try {
    const batch = await Batch.findById(req.params.id)
      .populate("manufacturerId", "name")
      .populate("vendorId", "name");
    if (!batch) return res.status(404).json({ error: "Batch not found" });
    res.json(batch);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
};

// Update batch
export const updateBatch = async (req, res) => {
  try {
    const { batchNumber, manufacturerId, vendorId, productionDate, expiryDate } = req.body;

    const batch = await Batch.findByIdAndUpdate(
      req.params.id,
      { batchNumber, manufacturerId, vendorId, productionDate, expiryDate },
      { new: true }
    );
    if (!batch) return res.status(404).json({ error: "Batch not found" });
    res.json(batch);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
};

// Delete batch
export const deleteBatch = async (req, res) => {
  try {
    const batch = await Batch.findByIdAndDelete(req.params.id);
    if (!batch) return res.status(404).json({ error: "Batch not found" });

    // Optionally, unset batchId from products
    await Product.updateMany({ batchId: batch._id }, { $unset: { batchId: "" } });

    res.json({ message: "Batch deleted" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
};
