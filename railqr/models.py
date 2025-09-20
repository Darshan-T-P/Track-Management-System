from fastapi import FastAPI, HTTPException
from fastapi.responses import FileResponse, JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, conint
from typing import List, Optional, Literal
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
    remarks: Optional[str] = None
    status: Literal["Passed", "Failed", "Pending"]  


class Review(BaseModel):
    reviewer: str
    date: Optional[datetime]=None
    feedback: str
    rating: conint(ge=1, le=5)  # type: ignore
    image: Optional[str] = None


class ProductDetails(BaseModel):
    # Identification
    product_name: str
    item_type: Literal["Clip", "Pad", "Liner", "Sleeper"]
    lot_number: str
    batch_id: Optional[str] = None
    tms_lot_reference: Optional[str] = None

    # Manufacturing
    manufacturer: str
    manufacturer_id: Optional[str] = None
    date_of_manufacture: datetime

    # Supply
    vendor: str
    vendor_id: Optional[str] = None
    date_of_supply: datetime

    # Warranty
    warranty_start_date: datetime
    warranty_end_date: datetime

    # Installation
    installation_date: datetime
    installation_location: str
    installed_by: str

    # Inspection history
    inspections: List[Inspection] = []
    last_inspection_date: Optional[datetime] = None

    # Reviews
    reviews: List[Review] = []

    # Extra
    description: Optional[str] = None
    category: Optional[str] = None
    serial_number: Optional[str] = None


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


# ---------------- API Routes ----------------

# 1. Initialize a product (generate QR + UUID)
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

    return {
        "uuid": product_id,
        "qr_code_url": f"http://127.0.0.1:8000/products/{product_id}/qr"
    }


# 2. Add product details
@app.post("/products/{uuid}/details")
async def add_product_details(uuid: str, details: ProductDetails):
    try:
        product = products_collection.find_one({"uuid": uuid})
        if not product:
            return JSONResponse(
                status_code=404,
                content={"success": False, "message": "Product not found"}
            )

        if product.get("details_entered", False):
            return JSONResponse(
                status_code=400,
                content={"success": False, "message": "Details already added"}
            )

        details_dict = details.dict()

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

        return JSONResponse(
            status_code=200,
            content={"success": True, "message": "Product details added successfully"}
        )

    except Exception as e:
        return JSONResponse(
            status_code=500,
            content={"success": False, "message": f"Error: {str(e)}"}
        )


# 3. Get product details (scan QR)
@app.get("/products/{uuid}")
def get_product(uuid: str):
    product = products_collection.find_one({"uuid": uuid}, {"_id": 0})
    if not product:
        raise HTTPException(404, "Product not found")

    # Convert datetime fields in details
    if product.get("details"):
        details = product["details"]

        # Main datetime fields
        for key in [
            "date_of_manufacture",
            "date_of_supply",
            "installation_date",
            "warranty_start_date",
            "warranty_end_date",
            "last_inspection_date",
        ]:
            value = details.get(key)
            if isinstance(value, datetime):
                details[key] = value.isoformat()

        # Inspections
        if details.get("inspections"):
            for ins in details["inspections"]:
                date_val = ins.get("date")
                if isinstance(date_val, datetime):
                    ins["date"] = date_val.isoformat()

        # Reviews
        if details.get("reviews"):
            for rev in details["reviews"]:
                date_val = rev.get("date")
                if isinstance(date_val, datetime):
                    rev["date"] = date_val.isoformat()

    return {
        "success": True,
        "product": product
    }


# 4. Get QR code image
@app.get("/products/{uuid}/qr")
def get_qr(uuid: str):
    qr_path = os.path.join(QR_DIR, f"{uuid}.png")
    if not os.path.exists(qr_path):
        raise HTTPException(404, "QR not found")
    return FileResponse(qr_path, media_type="image/png")


# 5. Add a review
@app.post("/products/{uuid}/reviews")
def add_review(uuid: str, review: Review):
    product = products_collection.find_one({"uuid": uuid})
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")

    if not product.get("details_entered", False):
        raise HTTPException(status_code=400, detail="Cannot add review before product details are entered")

    review_dict = review.dict()
    if not review_dict.get("date"):
        review_dict["date"] = datetime.utcnow()

    products_collection.update_one(
        {"uuid": uuid},
        {"$push": {"details.reviews": review_dict}}
    )

    return {"message": "Review added successfully", "review": review_dict}


# 6. Add an inspection
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
            "$set": {"details.last_inspection_date": inspection.date}
        }
    )
    return {"message": "Inspection added successfully"}


# 7. Update product details (only if not filled)
@app.post("/products/{uuid}/update")
def update_product(uuid: str, details: ProductDetails):
    product = products_collection.find_one({"uuid": uuid})
    if not product:
        raise HTTPException(status_code=404, detail="Product not found")

    if product.get("details_entered", False):
        raise HTTPException(status_code=400, detail="Details already filled")

    products_collection.update_one(
        {"uuid": uuid},
        {"$set": {"details": details.dict(), "details_entered": True}}
    )
    return {"success": True, "message": "Product details updated"}
