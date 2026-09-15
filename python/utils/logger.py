import logging
import os

# Create logs directory if it doesn't exist
LOG_DIR = os.path.join(
    os.path.dirname(__file__),
    "..",
    "logs"
)

os.makedirs(LOG_DIR, exist_ok=True)

LOG_FILE = os.path.join(LOG_DIR, "atfidp.log")

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s",
    handlers=[
        logging.FileHandler(LOG_FILE),
        logging.StreamHandler()
    ]
)

logger = logging.getLogger("ATFIDP")