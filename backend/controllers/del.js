require('dotenv').config();
const User = require('../models/authSchema');
const Delivery = require('../models/delSchema');
const jwt = require('jsonwebtoken')


const info = async (req, res) => {
    const token  = req.cookies.delivery_cookie;
    let id;
    if (token) {
        jwt.verify(token, process.env.SECRET_MESSAGE, async (err, decodedToken) => {
            if (err) {
                res.redirect('/user/login')
            } else {
                let user = await User.findById(decodedToken.id);
                id = user._id;
                next();
            }
        })
    } else {
        res.redirect('/user/login');
        next();
    }
    await Delivery.find({ user: id })
        .then((result) => res.status(200).json({ data: result }))
        .catch((err) => res.status(500).json({ error: 'Internal Server Error' }))
}

const save_info = (req, res) => {
    const token  = req.cookies.delivery_cookie;
    let id;
    if (token) {
        jwt.verify(token, process.env.SECRET_MESSAGE, async (err, decodedToken) => {
            if (err) {
                res.redirect('/user/login')
            } else {
                let user = await User.findById(decodedToken.id);
                id = user._id;
                next();
            }
        })
    } else {
        res.redirect('/user/login');
        next();
    }
    let delivery = new Delivery(req.body);
    console.log({ delivery });
    delivery.user = id;
    delivery.save()
        .then(res.status(201).json({ message: 'Delivery Details saved Successfully' }))
        .catch((err) => res.status(500).json({ error: 'Internal Server Error' }))
}


const change_info = (req, res) => {
    const id = req.params.id;
    try {

        
    } catch(error) {

    }

}

const delete_info = (req, res) => {
    const id = req.params.id;
    Delivery.findByIdAndDelete(id)
        .then(res.status(202).json({ message: 'Delivery details deleted successfully!' }))
        .catch((err) => res.status(500).json({ error: 'Internal Server Error' }))
}


module.exports = {
    info,
    save_info,
    change_info,
    delete_info
}