/* src/models/AuditLog.js */
const mongoose20 = require('mongoose');
const alSchema = new mongoose20.Schema({ userId:{type:mongoose20.Schema.Types.ObjectId,ref:'User'}, action:String, tableName:String, recordId:mongoose20.Schema.Types.ObjectId, oldValues:Object, newValues:Object, ipAddress:String, userAgent:String, createdAt:{type:Date,default:Date.now} });
module.exports = mongoose20.model('AuditLog', alSchema);