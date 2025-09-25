from fastapi import FastAPI, HTTPException, status
from fastapi.responses import FileResponse
from fastapi.middleware.cors import CORSMiddleware
from uuid import uuid4
import qrcode
import os
import logging
from datetime import datetime

from database import products_collection, Database
from models import ProductDetails, Review, Inspection

app = FastAPI(title="Railway QR System")

# Configure CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # ⚠️ Restrict in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

QR_DIR = "qr_codes"
os.makedirs(QR_DIR, exist_ok=True)


@app.on_event("startup")
async def startup_event():
    Database.connect()


@app.on_event("shutdown")
async def shutdown_event():
    Database.close()


# ---------------- 1. CREATE EMPTY PRODUCT (UUID + QR only) ----------------
# @app.post("/products/init")
# async def init_product():
#     try:
#         product_id = str(uuid4())
#         qr_filename = f"{product_id}.png"
#         qr_path = os.path.join(QR_DIR, qr_filename)

#         qr_data = f"http://127.0.0.1:8000/products/{product_id}"
#         qrcode.make(qr_data).save(qr_path)

#         product_record = {
#             "uuid": product_id,
#             "qr_code_url": f"/products/{product_id}/qr",
#             "details_entered": False,
#             "details": None,
#             "created_at": datetime.utcnow(),
#             "updated_at": datetime.utcnow(),
#         }
#         products_collection.insert_one(product_record)

#         logger.info(f"Initialized new product {product_id}")

#         return {
#             "uuid": product_id,
#             "qr_code_url": f"http://127.0.0.1:8000/products/{product_id}/qr",
#             "details_url": f"http://127.0.0.1:8000/products/{product_id}",
#         }
#     except Exception as e:
#         logger.error(f"Error creating product: {e}")
#         raise HTTPException(
#             status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
#             detail="Error creating product",
#         )
@app.get("/products/{uuid}/qr")
def generate_qr(uuid: str):
    qr_folder = "qrcodes"
    os.makedirs(qr_folder, exist_ok=True)
    file_path = f"{qr_folder}/{uuid}.png"

    # Generate QR if not exists
    if not os.path.exists(file_path):
        img = qrcode.make(uuid)
        img.save(file_path)

    return {"qr_code_url": f"http://localhost:8000/{file_path}"}


# ---------------- 2. ENTER DETAILS ----------------
@app.post("/products/{uuid}/details")
async def add_product_details(uuid: str, details: ProductDetails):
    try:
        product = products_collection.find_one({"uuid": uuid})
        if not product:
            raise HTTPException(404, "Product not found")

        if product.get("details_entered", False):
            raise HTTPException(400, "Details already added")

        details_dict = details.dict()

        # Auto-fill last inspection date if inspections exist
        if details.inspections:
            details_dict["last_inspection_date"] = max(
                ins.date for ins in details.inspections
            )

        products_collection.update_one(
            {"uuid": uuid},
            {
                "$set": {
                    "details": details_dict,
                    "details_entered": True,
                    "updated_at": datetime.utcnow(),
                }
            },
        )

        logger.info(f"Details added for product {uuid}")
        return {"message": "Product details added successfully"}
    except Exception as e:
        logger.error(f"Error adding product details for {uuid}: {e}")
        raise HTTPException(500, "Error adding product details")


# ---------------- 3. GET PRODUCT (SCANNING) ----------------
@app.get("/products/{uuid}")
async def get_product(uuid: str):
    product = products_collection.find_one({"uuid": uuid})
    if not product:
        raise HTTPException(404, "Product not found")

    product["_id"] = str(product["_id"])
    for field in ["created_at", "updated_at"]:
        if product.get(field):
            product[field] = product[field].isoformat()

    if product.get("details"):
        # Convert main datetime fields
        for key in [
            "date_of_manufacture",
            "date_of_supply",
            "installation_date",
            "warranty_start_date",
            "warranty_end_date",
            "last_inspection_date",
        ]:
            if product["details"].get(key):
                product["details"][key] = product["details"][key].isoformat()

        # Inspections
        if product["details"].get("inspections"):
            for ins in product["details"]["inspections"]:
                ins["date"] = ins["date"].isoformat()

        # Reviews
        if product["details"].get("reviews"):
            for rev in product["details"]["reviews"]:
                rev["date"] = rev["date"].isoformat()

    return {"success": True, "product": product}


# ---------------- 4. GET QR CODE IMAGE ----------------
@app.get("/products/{uuid}/qr")
def get_qr(uuid: str):
    qr_path = os.path.join(QR_DIR, f"{uuid}.png")
    if not os.path.exists(qr_path):
        raise HTTPException(404, "QR code not found")

    logger.info(f"QR retrieved for product {uuid}")
    return FileResponse(qr_path, media_type="image/png")


# ---------------- 5. ADD REVIEW ----------------
@app.post("/products/{uuid}/reviews")
def add_review(uuid: str, review: Review):
    product = products_collection.find_one({"uuid": uuid})
    if not product:
        raise HTTPException(404, "Product not found")

    if not product.get("details_entered", False):
        raise HTTPException(400, "Cannot add review before product details")

    review_data = review.dict()
    review_data["date"] = datetime.utcnow()

    products_collection.update_one(
        {"uuid": uuid}, {"$push": {"details.reviews": review_data}}
    )

    logger.info(f"Review added for product {uuid}")
    return {"message": "Review added successfully", "review": review_data}



# ---------------- 6. ADD INSPECTION ----------------
@app.post("/products/{uuid}/inspections")
def add_inspection(uuid: str, inspection: Inspection):
    product = products_collection.find_one({"uuid": uuid})
    if not product:
        raise HTTPException(404, "Product not found")

    if not product.get("details_entered", False):
        raise HTTPException(400, "Cannot add inspection before product details")

    products_collection.update_one(
        {"uuid": uuid},
        {
            "$push": {"details.inspections": inspection.dict()},
            "$set": {"details.last_inspection_date": inspection.date},
        },
    )

    logger.info(f"Inspection added for product {uuid}")
    return {"message": "Inspection added successfully"}
