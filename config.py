# Day Starter Configuration
# API Keys - Keep this file private and don't share

NEWS_API_KEY = "5c2c34de0cdd48ee969ad3c693378c0d"

# NewsAPI categories to fetch
NEWS_CATEGORIES = ["business", "technology"]

# Number of articles to fetch per category
ARTICLES_PER_CATEGORY = 10

# Max total articles to display
MAX_ARTICLES = 10

# Keywords for filtering TMT/Finance content
FINANCE_KEYWORDS = [
    # Market/Trading
    "stock", "market", "earnings", "share", "price", "nasdaq", "dow", "s&p", "ftse",
    "trading", "investment", "investor", "dividend", "portfolio", "fund", "ipo",
    # Big tech companies
    "apple", "google", "microsoft", "amazon", "meta", "tesla", "nvidia", "intel", "amd",
    "alphabet", "microsoft corp", "apple inc", "openai",
    # Telecom/Telco
    "telecom", "telco", "5g", "6g", "verizon", "at&t", "vodafone", "bt", "telefonica",
    "tmus", "deutsche telekom", "softbank", "mediaTek",
    # Media
    "disney", "netflix", "warner", "discovery", "paramount", "comcast",
    # Financial events
    "buyback", "acquisition", "merger", "wall street", "premarket", "after hours",
    "sec filing", "quarterly", "annual report", "revenue", "profit", "loss"
]
