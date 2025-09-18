const express = require('express');
const router = express.Router();
const ctrl = require('../../controllers/qrController');
const auth = require('../../middleware/authMiddleware');
router.post('/generate-batch', auth.required, ctrl.generateBatch);
router.get('/:qrCode', ctrl.getByCode);
router.post('/:qrCode/scan', ctrl.scan);
module.exports = router;