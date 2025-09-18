const mongoose3 = require('mongoose');
const dSchema = new mongoose3.Schema({ name:String, code:String, zoneId:{type:mongoose3.Schema.Types.ObjectId,ref:'Zone'}, description:String, status:String, createdAt:{type:Date,default:Date.now}, updatedAt:Date});
module.exports = mongoose3.model('Division', dSchema);