require("dotenv").config();
const User = require("../models/authSchema");
const Delivery = require("../../models/user/delSchema");
const jwt = require("jsonwebtoken");
const { checkForUser } = require("../../middlewares/authToken");

const info = async (req, res) => {
  const token = req.cookies.kiosk_cookie;
  try {
    const user = await checkForUser(token);
    const result = await Delivery.find({ user: user._id });
    return res.status(200).json({ data: result });
  } catch (err) {
    console.log({ error: err });
    return res.json({ error: "Internal Server Error" });
  }
};

const save_info = async (req, res) => {
  const token = req.cookies.kiosk_cookie;
  try {
    const user = await checkForUser(token);
    let delivery = new Delivery(req.body);
    delivery.user = user._id;
    await delivery.save();
    return res
      .status(201)
      .json({ message: "Delivery Details saved Successfully" });
  } catch (err) {
    console.log({ error: err });
    return res.json({ error: "Internal Server Error" });
  }
};

const change_info = (req, res) => {
  const id = req.params.id;
  try {
  } catch (error) {}
};

const delete_info = async (req, res) => {
  const id = req.params.id;
  try {
    await Delivery.findByIdAndDelete(id);
    return res.json({ message: "Delivery Details deleted Successfully" });
  } catch (err) {
    console.log({ error: err });
    return res.json({ error: "Internal Server Error" });
  }
};

module.exports = {
  info,
  save_info,
  change_info,
  delete_info,
};
