const express = require('express');
const router = express.Router();
const ctrl = require('../../controllers/referenceController');
// zones, divisions, stations, vendors, fitting categories/types, manufacturers
router.get('/zones', ctrl.listZones);
router.post('/zones', ctrl.createZone);
router.get('/divisions', ctrl.listDivisions);
router.post('/divisions', ctrl.createDivision);
router.get('/stations', ctrl.listStations);
router.post('/stations', ctrl.createStation);
router.get('/vendors', ctrl.listVendors);
router.post('/vendors', ctrl.createVendor);
router.get('/fitting-categories', ctrl.listFittingCategories);
router.post('/fitting-categories', ctrl.createFittingCategory);
router.get('/fitting-types', ctrl.listFittingTypes);
router.post('/fitting-types', ctrl.createFittingType);
router.get('/manufacturers', ctrl.listManufacturers);
router.post('/manufacturers', ctrl.createManufacturer);
module.exports = router;