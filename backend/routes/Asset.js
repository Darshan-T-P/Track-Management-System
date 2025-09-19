import express from 'express';
// import Asset from '../models/assets/Asset.js';
// import Report from '../models/assets/Reports.js';
// import Inspection from '../models/assets/Inspection.js';
import auth from '../middleware/auth.js';
import mongoose from 'mongoose';

const router = express.Router();
router.get("/:uuid", auth, async (req, res) => {
  try {
    const productsCollection = mongoose.connection.db.collection("products"); // explicitly use 'products'
    const product = await productsCollection.findOne({ uuid: req.params.uuid });

    if (!product) return res.status(404).json({ message: "Product not found" });

    res.json(product);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

export default router;