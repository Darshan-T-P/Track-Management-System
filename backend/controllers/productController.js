// controllers/productController.js
import { v4 as uuidv4 } from "uuid";
import axios from "axios";
import Product from "../models/Product.js";
import Manufacturer from "../models/Manufacturer.js";
import Vendor from "../models/Vendor.js";
import Batch from "../models/Batch.js";

export const createProduct = async (req, res) => {
  console.log("Request body:", req.body);
  try {
    const {
      productName,
      itemType,
      lotNumber,
      manufacturerId,
      vendorId,
      batchNumber,
      dateOfManufacture,
      dateOfSupply
    } = req.body;


    if (!productName || !itemType || !lotNumber || !manufacturerId || !vendorId || !dateOfManufacture || !dateOfSupply) {
      return res.status(400).json({ error: "Missing required fields" });
    }


    const manufacturer = await Manufacturer.findById(manufacturerId);
    const vendor = await Vendor.findById(vendorId);

    if (!manufacturer) return res.status(404).json({ error: "Manufacturer not found" });
    if (!vendor) return res.status(404).json({ error: "Vendor not found" });


    let batch;
    if (batchNumber) {
      batch = await Batch.findOne({ batchNumber });
      if (!batch) {
        batch = await Batch.create({
          batchNumber,
          manufacturerId,
          vendorId,
          productionDate: dateOfManufacture
        });
      }
    }


    const uuid = uuidv4();
    const qrResponse = await axios.get(`http://localhost:8000/products/${uuid}/qr`);

    const product = new Product({
      uuid,
      productName,
      itemType,
      lotNumber,
      manufacturerId,
      vendorId,
      batchId: batch?._id,
      dateOfManufacture,
      dateOfSupply,
      qrCodeUrl: qrResponse.data.qr_code_url
    });

    await product.save();

    // 6️⃣ Return populated product info
    const populatedProduct = await Product.findById(product._id)
      .populate("manufacturerId", "name")
      .populate("vendorId", "name")
      .populate("batchId", "batchNumber productionDate");

    res.status(201).json(populatedProduct);
    

  } catch (err) {
    console.error("Error in createProduct:", err.message);
    res.status(500).json({ error: err.message });
  }
};
