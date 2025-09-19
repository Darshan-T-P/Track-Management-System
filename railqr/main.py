from fastapi import FastAPI, HTTPException, status
from fastapi.responses import FileResponse, JSONResponse
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
    allow_origins=["*"],  # Adjust in production
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
@app.post("/products/init", response_model=dict)
async def init_product():
    try:
        product_id = str(uuid4())
        qr_filename = f"{product_id}.png"
        qr_path = os.path.join(QR_DIR, qr_filename)

        # Generate QR with UUID and base URL
        qr_data = f"http://127.0.0.1:8000/products/{product_id}"
        img = qrcode.make(qr_data)
        img.save(qr_path)

        # Insert empty record with timestamp
        product_record = {
            "uuid": product_id,
            "qr_code_url": f"/products/{product_id}/qr",
            "details_entered": False,
            "details": None,
            "created_at": datetime.utcnow(),
            "updated_at": datetime.utcnow()
        }
        products_collection.insert_one(product_record)

        return {
            "uuid": product_id,
            "qr_code_url": f"http://127.0.0.1:8000/products/{product_id}/qr",
            "details_url": f"http://127.0.0.1:8000/products/{product_id}"
        }
    except Exception as e:
        logger.error(f"Error creating product: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error creating product"
        )

# ---------------- 2. ENTER DETAILS AFTER FIRST SCAN ----------------
@app.post("/products/{uuid}/details")
async def add_product_details(uuid: str, details: ProductDetails):
    try:
        product = products_collection.find_one({"uuid": uuid})
        if not product:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Product not found"
            )

        if product.get("details_entered", False):
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Details already added for this product"
            )

        details_dict = details.dict()

        products_collection.update_one(
            {"uuid": uuid},
            {
                "$set": {
                    "details": details_dict,
                    "details_entered": True,
                    "updated_at": datetime.utcnow()
                }
            }
        )

        return {"message": "Product details added successfully"}
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error adding product details for {uuid}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error adding product details"
        )

# ---------------- 3. GET PRODUCT (SCANNING) ----------------
@app.get("/products/{uuid}")
async def get_product(uuid: str):
    try:
        product = products_collection.find_one({"uuid": uuid}, {"_id": 0})
        if not product:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Product not found"
            )

        # Format dates for better readability
        if product.get("details"):
            for date_field in ["date_of_manufacture", "date_of_supply", "installation_date"]:
                if product["details"].get(date_field):
                    product["details"][date_field] = product["details"][date_field].isoformat()
            
            # Format dates in inspections and reviews
            if product["details"].get("inspections"):
                for inspection in product["details"]["inspections"]:
                    inspection["date"] = inspection["date"].isoformat()
            
            if product["details"].get("reviews"):
                for review in product["details"]["reviews"]:
                    review["date"] = review["date"].isoformat()

        if not product.get("details_entered", False):
            return {
                "uuid": product["uuid"],
                "qr_code_url": product["qr_code_url"],
                "message": "Details not yet entered. Please add details.",
                "status": "pending"
            }

        # Add metadata to response
        product["metadata"] = {
            "created_at": product.get("created_at", "").isoformat() if product.get("created_at") else None,
            "updated_at": product.get("updated_at", "").isoformat() if product.get("updated_at") else None,
            "total_reviews": len(product["details"].get("reviews", [])),
            "total_inspections": len(product["details"].get("inspections", []))
        }

        return product
    except Exception as e:
        logger.error(f"Error retrieving product {uuid}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error retrieving product details"
        )

# ---------------- 4. GET QR CODE IMAGE ----------------
@app.get("/products/{uuid}/qr")
def get_qr(uuid: str):
    qr_path = os.path.join(QR_DIR, f"{uuid}.png")
    if not os.path.exists(qr_path):
        raise HTTPException(status_code=404, detail="QR code not found")
    return FileResponse(qr_path, media_type="image/png")

@app.post("/products/{uuid}/reviews")
def add_review(uuid: str, review: Review):
    product = products_collection.find_one({"uuid": uuid})
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")

    if not product.get("details_entered", False):
        raise HTTPException(status_code=400, detail="Cannot add review before product details are entered")

    products_collection.update_one(
        {"uuid": uuid},
        {"$push": {"details.reviews": review.dict()}}
    )

    return {"message": "Review added successfully"}

