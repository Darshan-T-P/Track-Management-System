// seedAssets.js
import mongoose from "mongoose";
import dotenv from "dotenv";
import Asset from "../models/assets/Asset.js";


dotenv.config();

const seedAssets = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });

    const assets = [
      {
        qrCode: "ASSET-001",
        type: "Rail Clip",
        location: "Chennai Central Yard Section 14",
        status: "OK",
        details: { manufacturer: "RailCorp", batch: "RC-2025-A" },
      },
      {
        qrCode: "ASSET-002",
        type: "Signal",
        location: "Salem Jn Platform 2",
        status: "OK",
        details: { voltage: "220V", model: "SIGX-55" },
      },
      {
        qrCode: "ASSET-003",
        type: "Joint",
        location: "Coimbatore North Yard Track 7",
        status: "OK",
        details: { size: "12mm", inspector: "Mr. Kumar" },
      },
    ];

    await Asset.deleteMany(); // Clear old assets
    await Asset.insertMany(assets);

    console.log("✅ Assets seeded successfully!");
    process.exit();
  } catch (err) {
    console.error("❌ Error seeding assets:", err);
    process.exit(1);
  }
};

seedAssets();
