const express = require('express');
const router = express.Router();
const ctrl = require('../../controllers/userController');
const auth = require('../../middleware/authMiddleware');
router.post('/register', ctrl.register);
router.post('/login', ctrl.login);
router.get('/', auth.required, ctrl.list);
module.exports = router;