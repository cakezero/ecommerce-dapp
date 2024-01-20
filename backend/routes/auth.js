const express = require('express');
const AUTH = require('../controllers/auth');
const requireAuth = require('../middlewares/authToken')

const router = express.Router();

router.post('/register', AUTH.register_post)
router.post('/login', AUTH.login_post);
router.get('/logout', AUTH.logout),
router.delete('/delete-user/:id', requireAuth, AUTH.delete_user)


module.exports = router;