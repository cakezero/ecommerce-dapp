const mongoose = require("mongoose");
const bcrypt = require("bcrypt");
const { isEmail } = require("validator");
const Schema = mongoose.Schema;

const merchantSchema = new Schema({
  fullName: {
    type: String,
    required: true,
    minLength: [5, "Full Name should be atleast 5 characters"],
  },
  bussinessName: {
    type: String,
    required: true,
    minLength: [4, "Bussiness Name should be atleast 4 characters"],
  },
  category: {
    type: String,
    required: true,
    minLength: [6, "category type should be atleast 4 characters"],
  },
  phoneNumber: {
    type: String,
    required: true,
    minLength: [8, "Phone number should be atleast 8 characters"],
  },
  officeAddress: {
    type: String,
    required: true,
    minLength: [50, "Office address should be atleast 50 characters"],
  },
  email: {
    type: String,
    required: true,
    validate: [isEmail, "Please enter a valid email address"],
  },
  password: {
    type: String,
    required: true,
    minLength: [8, "Minimum password length should be atleast 8 characters"],
  },
});

merchantSchema.pre("save", async function (next) {
  const salt = await bcrypt.genSaltSync(14);
  this.password = await bcrypt.hash(this.password, salt);
  next();
});

const merchant = mongoose.model("merchants", merchantSchema);

module.exports = merchant;
