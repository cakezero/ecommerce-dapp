require("dotenv").config();
const User = require("../models/authSchema");
const jwt = require("jsonwebtoken");
const { checkForUser } = require("../../middlewares/authToken");

//  MaxAge - 24 hours
const maxAge = 1 * 24 * 60 * 60;

// Token used for cookie creation
const createToken = (id) => {
  return jwt.sign({ id }, process.env.SECRET_MESSAGE, { expiresIn: maxAge });
};

// Register User
const register_post = async (req, res) => {
  const { fullName, username, email, password } = req.body;
  const user = await User.create({ fullName, username, email, password });
  try {
    const token = createToken(user._id);
    res.cookie("kiosk_cookie", token, {
      httpOnly: true,
      maxAge: maxAge * 1000,
    });
    return res.status(200).json({ user });
  } catch (err) {
    console.log({ error: err });
    return res.status(500).json({ error: "Internal Server Error" });
  }
};

// Login
const login_post = async (req, res) => {
  const { email, password } = req.body;
  const user = await User.login(email, password);
  try {
    const token = createToken(user._id);
    res.cookie("kiosk_cookie", token, {
      httpOnly: true,
      maxAge: maxAge * 1000,
    });
    return res.status(200).json({ user });
  } catch (err) {
    console.log({ error: err });
    return res.status(500).json({ error: "Internal Server Error" });
  }
};

const delete_user = async (req, res) => {
  const token = req.cookies.kiosk_cookie;
  try {
    const user = await checkForUser(token);
    await User.findByIdAndDelete(user._id);
    res.cookie("kiosk_cookie", "", { maxAge: 1 });
    return res.status(202).json({ message: "User deleted successfully" });
  } catch (err) {
    console.log({ error: err });
    return res.status(500).json({ error: "Something went wrong!!" });
  }
};

// Logout
const logout = (req, res) => {
  res.cookie("kiosk_cookie", "", { maxAge: 1 });
};

module.exports = {
  register_post,
  login_post,
  logout,
  delete_user,
};
