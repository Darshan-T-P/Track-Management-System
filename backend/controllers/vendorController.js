  // controllers/vendorController.js
  import Vendor from "../models/Vendor.js";

  // Create vendor
  export const createVendor = async (req, res) => {
    try {
      const { name, location, contact } = req.body;
      if (!name) return res.status(400).json({ error: "Name is required" });

      const vendor = new Vendor({ name, location, contact });
      await vendor.save();
      res.status(201).json(vendor);
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: "Server error" });
    }
  };

  // Get all vendors
// Get all vendors
export const getVendors = async (req, res) => {
  try {
    const vendors = await Vendor.find();

    // Pagination (optional)
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 10;
    const startIndex = (page - 1) * limit;
    const endIndex = page * limit;
    const paginatedVendors = vendors.slice(startIndex, endIndex);

    res.json({
      success: true,
      total: vendors.length,
      page,
      limit,
      vendors: paginatedVendors,
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
};


  // Get single vendor
  export const getVendorById = async (req, res) => {
    try {
      const vendor = await Vendor.findById(req.params.id);
      if (!vendor) return res.status(404).json({ error: "Vendor not found" });
      res.json(vendor);
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: "Server error" });
    }
  };

  // Update vendor
  export const updateVendor = async (req, res) => {
    try {
      const { name, location, contact } = req.body;
      const vendor = await Vendor.findByIdAndUpdate(
        req.params.id,
        { name, location, contact },
        { new: true }
      );
      if (!vendor) return res.status(404).json({ error: "Vendor not found" });
      res.json(vendor);
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: "Server error" });
    }
  };

  // Delete vendor
  export const deleteVendor = async (req, res) => {
    try {
      const vendor = await Vendor.findByIdAndDelete(req.params.id);
      if (!vendor) return res.status(404).json({ error: "Vendor not found" });
      res.json({ message: "Vendor deleted" });
    } catch (err) {
      console.error(err);
      res.status(500).json({ error: "Server error" });
    }
  };
