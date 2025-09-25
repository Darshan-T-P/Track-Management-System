// seed.js
import mongoose from "mongoose";
import Zone from "./models/Zone.js";
import Division from "./models/Division.js";
import Station from "./models/Station.js";
import Vendor from "./models/Vendor.js";
import Manufacturer from "./models/Manufacturer.js";

const MONGO_URI = "mongodb://127.0.0.1:27017/railway_fittings"; // change if needed

const seed = async () => {
  try {
    await mongoose.connect(MONGO_URI);
    console.log("✅ MongoDB connected");

    // Clear old data
    await Zone.deleteMany({});
    await Division.deleteMany({});
    await Station.deleteMany({});
    await Vendor.deleteMany({});
    await Manufacturer.deleteMany({});

    // Insert Zone
    const zone = await Zone.create({
      name: "Southern Railway",
      code: "SR",
      headquarters: "Chennai"
    });

    // Insert Division
    const division = await Division.create({
      name: "Chennai Division",
      code: "MAS",
      zoneId: zone._id,
      headquarters: "Chennai"
    });

    // Insert Station
    const station = await Station.create({
      name: "Chennai Central",
      code: "MAS",
      divisionId: division._id,
      zoneId: zone._id,
      location: { lat: 13.0827, lng: 80.2707 }
    });

    // Insert Vendor
    const vendor = await Vendor.create({
      name: "Rail Vendor Pvt Ltd",
      contactPerson: "Ravi Kumar",
      phone: "9876543210",
      email: "vendor@test.com",
      address: { city: "Chennai", state: "Tamil Nadu", country: "India" },
      gstin: "29ABCDE1234F1Z5",
      pannumber: "ABCDE1234F",
      isVerified: true,
      status: "active"
    });

    // Insert Manufacturer
    const manufacturer = await Manufacturer.create({
      name: "Rail Manufacturer Ltd",
      contactPerson: "Suresh",
      phone: "9123456780",
      email: "manufacturer@test.com",
      address: { city: "Coimbatore", state: "Tamil Nadu", country: "India" },
      gstin: "33ABCDE1234F1Z5",
      pannumber: "ABCDE1234F",
      isVerified: true,
      status: "active"
    });

    console.log("✅ Seeding completed successfully!");
    console.log("📌 Zone ID:", zone._id.toString());
    console.log("📌 Division ID:", division._id.toString());
    console.log("📌 Station ID:", station._id.toString());
    console.log("📌 Vendor ID:", vendor._id.toString());
    console.log("📌 Manufacturer ID:", manufacturer._id.toString());

    process.exit(0);
  } catch (err) {
    console.error("❌ Error seeding database:", err);
    process.exit(1);
  }
};

seed();
