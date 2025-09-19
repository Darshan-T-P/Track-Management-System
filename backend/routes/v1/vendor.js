import express from 'express';
import { 
    getVendors,
    getVendorById,
    createVendor,
    updateVendor,
    deleteVendor,
    changeVendorStatus,
    verifyVendor
} from '../controllers/vendorController.js';
import { authenticateToken } from '../middleware/auth.js';

const router = express.Router();

// Apply authentication middleware to all routes
router.use(authenticateToken);

// GET /api/v1/vendors - Get all vendors with pagination and filters
router.get('/', getVendors);

// GET /api/v1/vendors/:id - Get vendor by ID
router.get('/:id', getVendorById);

// POST /api/v1/vendors - Create new vendor
router.post('/', createVendor);

// PUT /api/v1/vendors/:id - Update vendor
router.put('/:id', updateVendor);

// DELETE /api/v1/vendors/:id - Delete vendor
router.delete('/:id', deleteVendor);

// PATCH /api/v1/vendors/:id/status - Change vendor status
router.patch('/:id/status', changeVendorStatus);

// PATCH /api/v1/vendors/:id/verify - Verify vendor
router.patch('/:id/verify', verifyVendor);

export default router;