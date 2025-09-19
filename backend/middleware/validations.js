import Joi from 'joi';

export const validateVendor = (data) => {
    const schema = Joi.object({
        name: Joi.string().required().min(2).max(100),
        contactPerson: Joi.string().min(2).max(100),
        phone: Joi.string().pattern(/^[0-9]{10}$/),
        email: Joi.string().email(),
        address: Joi.object({
            street: Joi.string(),
            city: Joi.string(),
            state: Joi.string(),
            country: Joi.string(),
            pincode: Joi.string()
        }),
        bankDetails: Joi.object({
            bankName: Joi.string(),
            accountNumber: Joi.string(),
            ifscCode: Joi.string(),
            accountType: Joi.string()
        }),
        website: Joi.string().uri().allow(''),
        rating: Joi.number().min(0).max(5),
        licenseNumber: Joi.string(),
        licenseExpiryDate: Joi.date(),
        gstin: Joi.string().pattern(/^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}$/),
        pannumber: Joi.string().pattern(/^[A-Z]{5}[0-9]{4}[A-Z]{1}$/),
        status: Joi.string().valid('active', 'blacklisted', 'pending'),
        isVerified: Joi.boolean()
    });

    return schema.validate(data);
};