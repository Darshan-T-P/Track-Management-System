import express from 'express';
import Asset from '../models/assets/Asset.js';
import Report from '../models/assets/Reports.js';
import Inspection from '../models/assets/Inspection.js';
import auth from '../middleware/auth.js';



const router = express.Router();
// Get asset by QR (id)
// 🔹 Get asset by QR code
router.get("/:qrCode", auth, async (req, res) => {
    try {
      const asset = await Asset.findOne({ qrCode: req.params.qrCode });
      if (!asset) return res.status(404).json({ message: "Asset not found" });
  
      const inspections = await Inspection.find({ asset: asset._id })
        .populate("inspector", "name email")
        .sort({ date: -1 });
  
      const reports = await Report.find({ asset: asset._id })
        .populate("reportedBy", "name email")
        .sort({ date: -1 });
  
      res.json({
        asset,
        inspectionHistory: inspections,
        reports,
      });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  });
  
  // 🔹 Log inspection
  router.post("/:qrCode/inspection", auth, async (req, res) => {
    try {
      const asset = await Asset.findOne({ qrCode: req.params.qrCode });
      if (!asset) return res.status(404).json({ message: "Asset not found" });
  
      const inspection = new Inspection({
        asset: asset._id,
        inspector: req.user.id,
        condition: req.body.condition,
        remarks: req.body.remarks,
      });
  
      asset.lastInspection = new Date();
      await asset.save();
      await inspection.save();
  
      res.json({ success: true, inspection });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  });
  
  // 🔹 Report an issue
  router.post("/:qrCode/report", auth, async (req, res) => {
    try {
      const asset = await Asset.findOne({ qrCode: req.params.qrCode });
      if (!asset) return res.status(404).json({ message: "Asset not found" });
  
      const report = new Report({
        asset: asset._id,
        reportedBy: req.user.id,
        issue: req.body.issue,
      });
  
      asset.status = "Faulty";
      await asset.save();
      await report.save();
  
      res.json({ success: true, report });
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  });
  
  export default router;