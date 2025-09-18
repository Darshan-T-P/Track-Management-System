const UserModel = require('../models/User');
const bcrypt2 = require('bcrypt');
exports.register = async (req, res, next) => {
try {
const { name, email, password } = req.body;
const exists = await UserModel.findOne({ email }); if (exists) return res.status(400).json({ success:false, message:'Email exists' });
const passwordHash = await bcrypt2.hash(password, 10);
const u = new UserModel({ name, email, passwordHash }); await u.save(); res.status(201).json({ success:true, data:{ user:u } });
} catch (err) { next(err); }
};
exports.login = async (req, res, next) => { /* alias to authController.login - keep simple */ res.status(501).json({ success:false, message:'Use /api/auth/login' }); };
exports.list = async (req, res, next) => { try { const users = await UserModel.find().limit(100); res.json({ success:true, data:{ users } }); } catch (err) { next(err); } };