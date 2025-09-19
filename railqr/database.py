from pymongo import MongoClient
from pymongo.errors import ConnectionFailure, ServerSelectionTimeoutError
import os
import logging
from typing import Optional

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

MONGO_URI = os.getenv("MONGO_URI", "mongodb://localhost:27017")
DB_NAME = os.getenv("DB_NAME", "tms")

class Database:
    client: Optional[MongoClient] = None
    db = None
    products_collection = None

    @classmethod
    def connect(cls):
        try:
            if not cls.client:
                cls.client = MongoClient(MONGO_URI)
                cls.db = cls.client[DB_NAME]
                cls.products_collection = cls.db["products"]
                # Test the connection
                cls.client.server_info()
                logger.info("Successfully connected to MongoDB")
        except (ConnectionFailure, ServerSelectionTimeoutError) as e:
            logger.error(f"Could not connect to MongoDB: {e}")
            raise

    @classmethod
    def close(cls):
        if cls.client:
            cls.client.close()
            cls.client = None
            logger.info("MongoDB connection closed")

# Initialize database connection
db = Database()
db.connect()
products_collection = db.products_collection
