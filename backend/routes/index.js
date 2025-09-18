const express = require('express');
const router = express.Router();
const authRoutes = require('./v1/auth');
const users = require('./v1/users');
const ref = require('./v1/reference');
const qr = require('./v1/qr');
const inspections = require('./v1/inspections');
const maintenance = require('./v1/maintance');


router.use('/auth', authRoutes);
router.use('/users', users);
router.use('/ref', ref);
router.use('/qr', qr);
router.use('/inspections', inspections);
router.use('/maintenance', maintenance);


module.exports = router;