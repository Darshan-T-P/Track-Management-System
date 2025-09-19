import Vendor from '../models/Vendor.js';
import { validateVendor } from '../middleware/validations.js';

// Get all vendors with pagination and filters
export const getVendors = async (req, res) => {
    try {
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 10;
        const status = req.query.status;
        const search = req.query.search;

        let query = {};
        
        // Add status filter if provided
        if (status) {
            query.status = status;
        }

        // Add search filter if provided
        if (search) {
            query.$or = [
                { name: { $regex: search, $options: 'i' } },
                { 'address.city': { $regex: search, $options: 'i' } },
                { email: { $regex: search, $options: 'i' } }
            ];
        }

        const vendors = await Vendor.find(query)
            .skip((page - 1) * limit)
            .limit(limit)
            .sort({ createdAt: -1 });

        const total = await Vendor.countDocuments(query);

        res.json({
            vendors,
            currentPage: page,
            totalPages: Math.ceil(total / limit),
            totalVendors: total
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Get vendor by ID
export const getVendorById = async (req, res) => {
    try {
        const vendor = await Vendor.findById(req.params.id);
        if (!vendor) {
            return res.status(404).json({ message: 'Vendor not found' });
        }
        res.json(vendor);
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Create new vendor
export const createVendor = async (req, res) => {
    try {
        const validation = validateVendor(req.body);
        if (validation.error) {
            return res.status(400).json({ message: validation.error.details[0].message });
        }

        const vendor = new Vendor(req.body);
        const savedVendor = await vendor.save();
        res.status(201).json(savedVendor);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

// Update vendor
export const updateVendor = async (req, res) => {
    try {
        const validation = validateVendor(req.body);
        if (validation.error) {
            return res.status(400).json({ message: validation.error.details[0].message });
        }

        const vendor = await Vendor.findByIdAndUpdate(
            req.params.id,
            { 
                ...req.body,
                updatedAt: new Date()
            },
            { new: true }
        );

        if (!vendor) {
            return res.status(404).json({ message: 'Vendor not found' });
        }

        res.json(vendor);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

// Delete vendor
export const deleteVendor = async (req, res) => {
    try {
        const vendor = await Vendor.findByIdAndDelete(req.params.id);
        if (!vendor) {
            return res.status(404).json({ message: 'Vendor not found' });
        }
        res.json({ message: 'Vendor deleted successfully' });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// Change vendor status
export const changeVendorStatus = async (req, res) => {
    try {
        const { status } = req.body;
        if (!['active', 'blacklisted', 'pending'].includes(status)) {
            return res.status(400).json({ message: 'Invalid status' });
        }

        const vendor = await Vendor.findByIdAndUpdate(
            req.params.id,
            { 
                status,
                updatedAt: new Date()
            },
            { new: true }
        );

        if (!vendor) {
            return res.status(404).json({ message: 'Vendor not found' });
        }

        res.json(vendor);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

// Verify vendor
export const verifyVendor = async (req, res) => {
    try {
        const vendor = await Vendor.findByIdAndUpdate(
            req.params.id,
            { 
                isVerified: true,
                updatedAt: new Date()
            },
            { new: true }
        );

        if (!vendor) {
            return res.status(404).json({ message: 'Vendor not found' });
        }

        res.json(vendor);
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};