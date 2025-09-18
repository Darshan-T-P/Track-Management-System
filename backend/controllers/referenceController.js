const Zone = require('../models/Zone');
const Division = require('../models/Division');
const Station = require('../models/Station');
const Vendor = require('../models/Vendor');
const FittingCategory = require('../models/FittingCategory');
const FittingType = require('../models/FittingType');
const Manufacturer = require('../models/Manufacturer');


exports.listZones = async (req, res, next) => { try { const z = await Zone.find(); res.json({ success:true, data:{ zones:z } }); } catch (e){ next(e); } };
exports.createZone = async (req, res, next) => { try { const z = new Zone(req.body); await z.save(); res.status(201).json({ success:true, data:{ zone:z } }); } catch (e){ next(e); } };
exports.listDivisions = async (req, res, next) => { try { const d = await Division.find(); res.json({ success:true, data:{ divisions:d } }); } catch (e){ next(e); } };
exports.createDivision = async (req, res, next) => { try { const d = new Division(req.body); await d.save(); res.status(201).json({ success:true, data:{ division:d } }); } catch (e){ next(e); } };
exports.listStations = async (req, res, next) => { try { const s = await Station.find(); res.json({ success:true, data:{ stations:s } }); } catch (e){ next(e); } };
exports.createStation = async (req, res, next) => { try { const s = new Station(req.body); await s.save(); res.status(201).json({ success:true, data:{ station:s } }); } catch (e){ next(e); } };
exports.listVendors = async (req, res, next) => { try { const v = await Vendor.find(); res.json({ success:true, data:{ vendors:v } }); } catch (e){ next(e); } };
exports.createVendor = async (req, res, next) => { try { const v = new Vendor(req.body); await v.save(); res.status(201).json({ success:true, data:{ vendor:v } }); } catch (e){ next(e); } };
exports.listFittingCategories = async (req, res, next) => { try { const c = await FittingCategory.find(); res.json({ success:true, data:{ categories:c } }); } catch (e){ next(e); } };
exports.createFittingCategory = async (req, res, next) => { try { const c = new FittingCategory(req.body); await c.save(); res.status(201).json({ success:true, data:{ category:c } }); } catch (e){ next(e); } };
exports.listFittingTypes = async (req, res, next) => { try { const t = await FittingType.find(); res.json({ success:true, data:{ types:t } }); } catch (e){ next(e); } };
exports.createFittingType = async (req, res, next) => { try { const t = new FittingType(req.body); await t.save(); res.status(201).json({ success:true, data:{ type:t } }); } catch (e){ next(e); } };
exports.listManufacturers = async (req, res, next) => { try { const m = await Manufacturer.find(); res.json({ success:true, data:{ manufacturers:m } }); } catch (e){ next(e); } };
exports.createManufacturer = async (req, res, next) => { try { const m = new Manufacturer(req.body); await m.save(); res.status(201).json({ success:true, data:{ manufacturer:m } }); } catch (e){ next(e); } };