from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime


class Inspection(BaseModel):
    date: datetime
    inspector: str
    remarks: str


class Review(BaseModel):
    reviewer: str
    date: datetime
    feedback: str
    image: Optional[str] = None  # URL or path to image
    rating: int  # 1-5 scale


class ProductDetails(BaseModel):
    # Manufacturing details
    manufacturer: str
    lot_number: str
    batch_id: Optional[str] = None
    date_of_manufacture: datetime

    # Supply details
    vendor: str
    date_of_supply: datetime
    warranty_period: str

    # Installation details
    installation_date: datetime
    installation_location: str
    installed_by: str

    # Inspection history
    inspections: List[Inspection] = []

    # Reviews / performance feedback
    reviews: List[Review] = []

    # Additional fields for product info
    product_name: str
    description: Optional[str] = None
    category: Optional[str] = None
    serial_number: Optional[str] = None

from fastapi import FastAPI, HTTPException
from fastapi.responses import FileResponse
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware
from typing import List, Optional
from datetime import datetime
from pymongo import MongoClient
from uuid import uuid4
import qrcode, os

# ---------------- DB ----------------
MONGO_URI = os.getenv("MONGO_URI", "mongodb://localhost:27017")
client = MongoClient(MONGO_URI)
db = client["tms"]
products_collection = db["products"]

# ---------------- Models ----------------
class Inspection(BaseModel):
    date: datetime
    inspector: str
    remarks: str

class Review(BaseModel):
    reviewer: str
    date: datetime
    feedback: str
    rating: int

class ProductDetails(BaseModel):
    manufacturer: str
    lot_number: str
    batch_id: Optional[str] = None
    date_of_manufacture: datetime
    vendor: str
    date_of_supply: datetime
    warranty_period: str
    installation_date: datetime
    installation_location: str
    installed_by: str
    inspections: List[Inspection] = []
    reviews: List[Review] = []

# ---------------- FastAPI ----------------
app = FastAPI(title="Railway QR System")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

QR_DIR = "qr_codes"
os.makedirs(QR_DIR, exist_ok=True)

@app.post("/products/init")
def init_product():
    product_id = str(uuid4())
    qr_filename = f"{product_id}.png"
    qr_path = os.path.join(QR_DIR, qr_filename)
    qrcode.make(product_id).save(qr_path)

    products_collection.insert_one({
        "uuid": product_id,
        "qr_code_url": f"/products/{product_id}/qr",
        "details_entered": False,
        "details": None
    })

    return {"uuid": product_id, "qr_code_url": f"http://127.0.0.1:8000/products/{product_id}/qr"}

@app.post("/products/{uuid}/details")
def add_product_details(uuid: str, details: ProductDetails):
    product = products_collection.find_one({"uuid": uuid})
    if not product:
        raise HTTPException(404, "Product not found")
    if product.get("details_entered", False):
        raise HTTPException(400, "Details already added")

    products_collection.update_one(
        {"uuid": uuid},
        {"$set": {"details": details.dict(), "details_entered": True}}
    )
    return {"message": "Product details added successfully"}

# ---------------- GET PRODUCT (SCANNING) ---------------- 
@app.get("/products/{uuid}")
def get_product(uuid: str):
    product = products_collection.find_one({"uuid": uuid}, {"_id": 0})
    if not product:
        raise HTTPException(404, "Product not found")
    return product

# ---------------- GET QR IMAGE ----------------
@app.get("/products/{uuid}/qr")
def get_qr(uuid: str):
    qr_path = os.path.join(QR_DIR, f"{uuid}.png")
    if not os.path.exists(qr_path):
        raise HTTPException(404, "QR not found")
    return FileResponse(qr_path, media_type="image/png")

# ---------------- ADD REVIEW ----------------
@app.post("/products/{uuid}/reviews")
def add_review(uuid: str, review: Review):
    product = products_collection.find_one({"uuid": uuid})
    if not product:
        raise HTTPException(404, "Product not found")
    if not product.get("details_entered", False):
        raise HTTPException(400, "Cannot add review before product details")

    products_collection.update_one(
        {"uuid": uuid},
        {"$push": {"details.reviews": review.dict()}}
    )
    return {"message": "Review added successfully"}

# ---------------- UPDATE PRODUCT DETAILS (IF NOT FILLED) ----------------
@app.post("/update_product/{uuid}")
def update_product(uuid: str, details: ProductDetails):
    product = products_collection.find_one({"uuid": uuid})
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")

    # allow update only if details not already filled
    if "manufacturer" in product:
        raise HTTPException(status_code=400, detail="Details already filled")

    products_collection.update_one(
        {"uuid": uuid},
        {"$set": details.dict()}
    )
    return {"success": True, "message": "Product details updated"}