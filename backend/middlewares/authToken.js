require('dotenv').config();
const jwt = require('jsonwebtoken');
const User = require('../models/user/userSchema')
const Merchant = require('../models/merchant/merchantSchema')


const checkForUser = (token) => {
    return jwt.verify(token, process.env.SECRET_MESSAGE, async (err, decodedToken) => {
        if (err) {
            throw new Error('Something went wrong. Kindly logout and log back in!')
        }
        const user = await User.findById(decodedToken.id)
        if (!user) {
            throw new Error('Something went wrong. Kindly logout and log back in!') 
        }
        return user;
    })
}

const checkForMerchant = (token) => {
    return jwt.verify(token, process.env.MERCHANT_SECRET_MESSAGE, async (err, decodedToken) => {
        if (err) {
            throw new Error('Something went wrong. Kindly logout and log back in!')
        }
        const merchant = await Merchant.findById(decodedToken.id)
        if (!merchant) {
            throw new Error('Something went wrong. Kindly logout and log back in!') 
        }
        return merchant;
    })
}

const requireAuth = async (req, res, next) => {
    const token = req.cookies.delivery_cookie;
    if (!token) {
        res.redirect('/user/login');
        next();
    }
    const user = await checkForUser(token);

    if (!user) {
        res.redirect('/user/login');
        next();
    }

    console.log('User Confirmed!');
    next();
};


module.exports = {
    requireAuth,
    checkForUser,
    checkForMerchant
};