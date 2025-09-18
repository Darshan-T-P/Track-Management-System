const express = require('express');
const router = express.Router();
const ctrl = require('../../controllers/maintenanceController');
const auth = require('../../middleware/authMiddleware');
router.post('/', auth.required, ctrl.createMaintenance);
router.get('/', auth.required, ctrl.listMaintenance);
module.exports = router;