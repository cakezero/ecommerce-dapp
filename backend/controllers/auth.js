require('dotenv').config();
const User = require('../models/authSchema');
const jwt = require('jsonwebtoken');

//  MaxAge
const maxAge = 1 * 24 * 60 * 60

// Token used for cookie creation
const createToken = (id) => {
    return jwt.sign({ id }, process.env.SECRET_MESSAGE, { expiresIn: maxAge });
}

// Register User
const register_post = async (req, res) => {
    const { fullname, username, email, password } = req.body;
    const user = await User.create({ fullname, username, email, password });
    try {
        const token = createToken(user._id);
        res.cookie('delivery_cookie', token, { httpOnly: true, maxAge: maxAge * 1000 });
        res.status(200).json({ user });
    } 
    catch (err) {  
        res.status(500).json({ error: 'Internal Server Error' });
    }
};

// Login
const login_post = async (req, res) => {
    const { email, password } = req.body;
    const user = await User.login(email, password);
    try {
        const token = createToken(user._id);
        res.cookie('delivery_cookie', token, { httpOnly: true, maxAge: maxAge * 1000 });
        res.status(200).json({ user });
    } catch (err) {
        res.status(500).json({ error: 'Internal Server Error' })
    }
};

const delete_user = (req, res) => {
    const id = req.params.id;
    User.findByIdAndDelete(id)
        .then(res.status(202).json({ message: 'User deleted successfully!' }))
        .catch((err) => res.status(500).json({ error: 'Internal Server Error' }))
}

// Logout
const logout = (req, res) => {
    res.cookie('delivery_cookie', '', { maxAge: 1 });
}

module.exports = {
    register_post,
    login_post,
    logout,
    delete_user
}
