// const express = require('express');
// const dotenv = require('dotenv');
// const helmet = require('helmet');
// const morgan = require('morgan');
// const cors = require('cors');
// const path = require('path');


// dotenv.config();
// const connectDB = require('./config/db');
// const routes = require('./routes');


// const app = express();
// const PORT = process.env.PORT || 4000;


// connectDB();
// app.use(helmet());
// app.use(cors());
// app.use(express.json({ limit: '10mb' }));
// app.use(express.urlencoded({ extended: true }));
// app.use(morgan('dev'));
// app.use('/uploads', express.static(path.join(__dirname, '..', process.env.UPLOAD_DIR || 'uploads')));
// app.use('/api', routes);
// app.get('/', (req, res) => res.json({ success: true, message: 'SIH PS21 Backend' }));
// app.use((err, req, res, next) => { console.error(err); res.status(err.status||500).json({ success:false, message: err.message||'Server error' }); });


import express from "express";
import mongoose from "mongoose";
import dotenv from "dotenv";
import cors from "cors";

import authRoutes from "./routes/auth.js";
import assetRoutes from "./routes/Asset.js"; 
 

dotenv.config();
const app = express();


// middleware
app.use(express.json());
app.use(cors());

// DB connection
mongoose.connect(process.env.MONGO_URI)
  .then(() => console.log('MongoDB Connected'))
  .catch(err => console.error(err));

// test route
app.get('/', (req, res) => {
  res.send('Backend is running 🚀');
});

app.use('/api/auth', authRoutes);
app.use('/api/assets', assetRoutes);

const PORT = process.env.PORT || 4000;
app.listen(PORT, () => console.log(`Server running on ${PORT}`));
