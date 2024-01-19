const express = require('express');
const AUTH = require('../controllers/auth');

const router = express.Router();

router.get('/register', AUTH.register);
router.post('/register', AUTH.register_post)
router.get('/login', AUTH.login);
router.post('/login', AUTH.login_post);
router.get('/logout', AUTH.logout),


module.exports = router;