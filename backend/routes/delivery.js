const express = require('express');
const DEL = require('../controllers/del');

const router = express.Router();

router.get('/', DEL.info);
router.post('/save-delivery-info', DEL.save_info)
router.put('/change-info/:id', DEL.change_info);
router.delete('/delete-info/:id', DEL.delete_info);


module.exports = router;