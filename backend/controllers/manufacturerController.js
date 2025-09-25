// controllers/manufacturerController.js
import Manufacturer from "../models/Manufacturer.js";

// Create a new manufacturer
export const createManufacturer = async (req, res) => {
  try {
    const { name, location, contact } = req.body;
    if (!name) return res.status(400).json({ error: "Name is required" });

    const manufacturer = new Manufacturer({ name, location, contact });
    await manufacturer.save();
    res.status(201).json(manufacturer);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
};

// Get all manufacturers
export const getManufacturers = async (req, res) => {
  try {
    const manufacturers = await Manufacturer.find();
    res.json(manufacturers);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
};

// Get single manufacturer
export const getManufacturerById = async (req, res) => {
  try {
    const manufacturer = await Manufacturer.findById(req.params.id);
    if (!manufacturer) return res.status(404).json({ error: "Manufacturer not found" });
    res.json(manufacturer);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
};

// Update manufacturer
export const updateManufacturer = async (req, res) => {
  try {
    const { name, location, contact } = req.body;
    const manufacturer = await Manufacturer.findByIdAndUpdate(
      req.params.id,
      { name, location, contact },
      { new: true }
    );
    if (!manufacturer) return res.status(404).json({ error: "Manufacturer not found" });
    res.json(manufacturer);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
};

// Delete manufacturer
export const deleteManufacturer = async (req, res) => {
  try {
    const manufacturer = await Manufacturer.findByIdAndDelete(req.params.id);
    if (!manufacturer) return res.status(404).json({ error: "Manufacturer not found" });
    res.json({ message: "Manufacturer deleted" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Server error" });
  }
};
