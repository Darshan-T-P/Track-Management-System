import express from "express";
import mongoose from "mongoose";
import dotenv from "dotenv";
import cors from "cors";
import morgan from "morgan";
import authRoutes from "./routes/auth.js";
import productRoutes from "./routes/productRoutes.js";
import manufacturerRoutes from "./routes/manufacturerRoutes.js";
import vendorRoutes from "./routes/vendorRoutes.js";
import batchRoutes from "./routes/batchRoutes.js";
import { errorHandler } from "./middleware/errorHandler.js";


dotenv.config();
const app = express();  

app.use(morgan("dev"));
// middleware
app.use(express.json());
app.use(cors());
app.use("/api/manufacturers", manufacturerRoutes);
app.use("/api/vendors", vendorRoutes);
app.use("/api/batches", batchRoutes);

// DB connection
mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log('MongoDB Connected'))
  .catch(err => console.error(err));

// test route
app.get('/', (req, res) => {
  res.send('Backend is running 🚀 Succedfully');
});

app.use('/api/auth', authRoutes);
app.use("/api/products", productRoutes);
app.use("/api/batches", batchRoutes);

// Global error handler
app.use(errorHandler);


const PORT = process.env.PORT || 5000;
app.listen(PORT, '0.0.0.0', () => console.log(`Server running on ${PORT}`));

