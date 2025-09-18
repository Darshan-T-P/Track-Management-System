const express = require('express');
const router = express.Router();
const ctrl = require('../../controllers/inspectionController');
const auth = require('../../middleware/authMiddleware');
router.post('/', auth.required, ctrl.createInspection);
router.get('/', auth.required, ctrl.listInspections);
module.exports = router;