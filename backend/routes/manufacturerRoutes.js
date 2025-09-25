// routes/manufacturerRoutes.js
import express from "express";
import {
  createManufacturer,
  getManufacturers,
  getManufacturerById,
  updateManufacturer,
  deleteManufacturer,
} from "../controllers/manufacturerController.js";

const router = express.Router();

router.post("/", createManufacturer);
router.get("/", getManufacturers);
router.get("/:id", getManufacturerById);
router.put("/:id", updateManufacturer);
router.delete("/:id", deleteManufacturer);

export default router;
