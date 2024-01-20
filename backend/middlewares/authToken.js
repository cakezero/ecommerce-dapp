require('dotenv').config();
const jwt = require('jsonwebtoken');
const User = require('../models/authSchema')

const requireAuth = (req, res, next) => {
    const token = req.cookies.delivery_cookie;
    if (token) {
        jwt.verify(token, process.env.SECRET_MESSAGE, (err, decodedToken) => {
            if (err) {
                res.redirect('/user/login');
                next();
            } else {
                const user = User.findById(decodedToken.id);
                if (user) {
                    console.log('User Confirmed!');
                    next();
                } else {
                    res.redirect('/user/login');
                    next();
                }
            }
        })
    } else {
        res.redirect('/user/login');
        next();
    }
};


module.exports = requireAuth;