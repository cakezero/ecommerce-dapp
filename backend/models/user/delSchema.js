const mongoose = require('mongoose');
const Schema = mongoose.Schema;
const Users = require('./authSchema');

const deliverySchema = new Schema({
    address: {
        type: String,
        required: true
    },
    phoneNumber: {
        type: String,
        required: true
    },
    country: {
        type: String,
        required: true
    },
    state: {
        type: String,
        required: true
    },
    region: {
        type: String,
        required: true
    },
    user: {
        type: mongoose.Schema.ObjectId,
        ref: 'Users'
    }
}, { timestamps: true });

deliverySchema.pre('remove', function(next) {
    Delivery.remove({ user: this._id }).exec();
    next();
});

const Delivery = mongoose.model('Delivery', deliverySchema);

module.exports = Delivery;