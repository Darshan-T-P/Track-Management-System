const mongoose4 = require('mongoose');
const sSchema = new mongoose4.Schema({ name:String, code:String, divisionId:{type:mongoose4.Schema.Types.ObjectId,ref:'Division'}, description:String, status:String, createdAt:{type:Date,default:Date.now}, updatedAt:Date });
module.exports = mongoose4.model('Station', sSchema);