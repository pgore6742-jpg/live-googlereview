-- =========================================================================
-- SmartReview AI - Cloudflare D1 Database Schema
-- Database Name suggestion: smartreview-db
-- Target: Cloudflare D1 (SQLite Engine)
-- =========================================================================

-- Drop existing tables if re-initializing (safe for fresh setup)
DROP TABLE IF EXISTS reviews_feedback;
DROP TABLE IF EXISTS analytics_logs;
DROP TABLE IF EXISTS shops;

-- =========================================================================
-- 1. SHOPS TABLE
-- Stores client business metadata, dynamic routing destinations, and QR themes
-- =========================================================================
CREATE TABLE IF NOT EXISTS shops (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  category TEXT NOT NULL,
  area TEXT NOT NULL,
  city TEXT NOT NULL,
  seo_keywords TEXT,               -- Stored as JSON array string
  google_review_url TEXT NOT NULL,
  owner_phone TEXT NOT NULL,
  instagram_url TEXT,
  promo_offer TEXT,
  promo_code TEXT,
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'paused')),
  expiry_date TEXT,
  avatar_emoji TEXT DEFAULT '🏪',
  brand_color TEXT DEFAULT 'indigo',
  rating REAL DEFAULT 4.8,
  review_count INTEGER DEFAULT 0,
  custom_tags TEXT,                -- Stored as JSON array string
  routing_mode TEXT DEFAULT 'default' CHECK (routing_mode IN ('default', 'direct-google', 'custom-redirect')),
  custom_redirect_url TEXT,
  qr_color TEXT DEFAULT '#0f172a',
  qr_frame_label TEXT,
  created_at TEXT DEFAULT (datetime('now'))
);

CREATE INDEX IF NOT EXISTS idx_shops_slug ON shops(slug);
CREATE INDEX IF NOT EXISTS idx_shops_status ON shops(status);

-- =========================================================================
-- 2. DAILY ANALYTICS TABLE
-- Stores tap counts, positive 4-5 star forwards, and 1-3 star shielded comments
-- =========================================================================
CREATE TABLE IF NOT EXISTS analytics_logs (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  shop_id TEXT NOT NULL,
  date TEXT NOT NULL,              -- Format: YYYY-MM-DD
  taps INTEGER DEFAULT 0,
  good_reviews INTEGER DEFAULT 0,
  bad_comments INTEGER DEFAULT 0,
  FOREIGN KEY (shop_id) REFERENCES shops(id) ON DELETE CASCADE,
  UNIQUE(shop_id, date)
);

CREATE INDEX IF NOT EXISTS idx_analytics_shop_date ON analytics_logs(shop_id, date);

-- =========================================================================
-- 3. REVIEWS & FEEDBACK TABLE
-- Stores both 1-3 star private complaints and 4-5 star AI-assisted reviews
-- =========================================================================
CREATE TABLE IF NOT EXISTS reviews_feedback (
  id TEXT PRIMARY KEY,
  shop_id TEXT NOT NULL,
  shop_name TEXT NOT NULL,
  customer_name TEXT DEFAULT 'Valued Guest',
  customer_phone TEXT,
  rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  review_type TEXT NOT NULL CHECK (review_type IN ('good', 'bad')),
  complaint_or_review TEXT NOT NULL,
  selected_tags TEXT,              -- JSON array string or comma separated
  language TEXT DEFAULT 'English',
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'contacted', 'resolved')),
  sent_via_whatsapp INTEGER DEFAULT 0,
  timestamp TEXT DEFAULT (datetime('now')),
  FOREIGN KEY (shop_id) REFERENCES shops(id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_feedback_shop ON reviews_feedback(shop_id, timestamp);
CREATE INDEX IF NOT EXISTS idx_feedback_type ON reviews_feedback(review_type);

-- =========================================================================
-- SEED DATA: 3 INITIAL AMRAVATI DEMO SHOPS
-- =========================================================================
INSERT INTO shops (
  id, name, slug, category, area, city, seo_keywords,
  google_review_url, owner_phone, instagram_url, promo_offer, promo_code,
  status, expiry_date, avatar_emoji, brand_color, rating, review_count,
  custom_tags, routing_mode, custom_redirect_url, qr_color, qr_frame_label, created_at
) VALUES 
(
  'shop-1',
  'Bean & Brew Cafe',
  'bean-and-brew-cafe',
  'Cafe',
  'Camp, Amravati',
  'Amravati',
  '["best coffee in amravati", "cozy cafe camp amravati", "cold brew", "artisan bakery", "work friendly cafe"]',
  'https://search.google.com/local/writereview?placeid=ChIJbeanandbrewcampamravati',
  '919876543210',
  'https://instagram.com/beanandbrew.amravati',
  'Review us & get 15% OFF on your coffee & bakery order!',
  'CAMPCOFFEE15',
  'active',
  '2027-12-31',
  '☕',
  'indigo',
  4.8,
  342,
  '["Best Coffee", "Cozy Ambience", "Polite Staff", "Fast Wi-Fi", "Yummy Pastries", "Value for Money"]',
  'default',
  'https://instagram.com/beanandbrew.amravati',
  '#4f46e5',
  'Scan to Review Bean & Brew',
  '2026-01-10T10:00:00.000Z'
),
(
  'shop-2',
  'Glow Unisex Salon & Spa',
  'glow-unisex-salon',
  'Salon',
  'Gadge Nagar, Amravati',
  'Amravati',
  '["best salon in amravati", "hair spa gadge nagar", "bridal makeover amravati", "hydra facial", "expert hair stylist"]',
  'https://search.google.com/local/writereview?placeid=ChIJglowsalonamravati',
  '919822001122',
  'https://instagram.com/glowsalon.amravati',
  'Leave a 5-star review & get a FREE Hair Spa upgrade voucher!',
  'GLOWHAIRSPA',
  'active',
  '2027-11-15',
  '💇‍♀️',
  'emerald',
  4.9,
  518,
  '["Expert Stylists", "Hygienic Place", "Polite Staff", "Great Haircut", "Relaxing Ambience", "Value for Money"]',
  'default',
  'https://glowsalon.amravati/festive-offer',
  '#059669',
  'Scan to Review Glow Salon',
  '2026-02-01T11:30:00.000Z'
),
(
  'shop-3',
  'Smile Care Advanced Dental Clinic',
  'smile-care-dental',
  'Clinic',
  'Irwin Chowk, Amravati',
  'Amravati',
  '["best dentist in amravati", "painless root canal irwin chowk", "teeth whitening", "dental implant clinic amravati", "gentle doctor"]',
  'https://search.google.com/local/writereview?placeid=ChIJsmilecaredentalirwinchowk',
  '919423112233',
  'https://instagram.com/smilecare.amravati',
  'Share your feedback & receive a complimentary Dental Hygiene Kit!',
  'HEALTHYSMILE',
  'active',
  '2027-09-30',
  '🦷',
  'cyan',
  4.9,
  420,
  '["Painless Treatment", "Caring Doctor", "Clean Clinic", "Modern Equipment", "Affordable Care", "Highly Recommended"]',
  'default',
  'https://smilecareamravati.in',
  '#0284c7',
  'Scan to Review Smile Care Dental',
  '2026-03-05T09:15:00.000Z'
);

-- =========================================================================
-- SEED DATA: SAMPLE DAILY METRICS FOR OCTOBER 2026
-- =========================================================================
INSERT INTO analytics_logs (shop_id, date, taps, good_reviews, bad_comments) VALUES
('shop-1', '2026-10-01', 12, 10, 1),
('shop-1', '2026-10-03', 15, 13, 2),
('shop-1', '2026-10-05', 9, 8, 1),
('shop-1', '2026-10-07', 18, 16, 1),
('shop-1', '2026-10-10', 22, 19, 2),
('shop-1', '2026-10-12', 14, 12, 1),
('shop-1', '2026-10-14', 16, 15, 1),
('shop-1', '2026-10-16', 20, 17, 2),
('shop-1', '2026-10-17', 19, 18, 1),
('shop-2', '2026-10-01', 14, 12, 1),
('shop-2', '2026-10-04', 21, 19, 1),
('shop-2', '2026-10-08', 19, 17, 2),
('shop-2', '2026-10-12', 25, 23, 1),
('shop-2', '2026-10-15', 28, 25, 2),
('shop-2', '2026-10-17', 22, 20, 1),
('shop-3', '2026-10-02', 10, 9, 0),
('shop-3', '2026-10-06', 15, 14, 1),
('shop-3', '2026-10-10', 12, 11, 0),
('shop-3', '2026-10-14', 16, 15, 1),
('shop-3', '2026-10-17', 14, 13, 0);

-- =========================================================================
-- SEED DATA: NEGATIVE SHIELDED FEEDBACK (1-3 STARS)
-- =========================================================================
INSERT INTO reviews_feedback (
  id, shop_id, shop_name, customer_name, customer_phone, rating,
  review_type, complaint_or_review, status, sent_via_whatsapp, timestamp
) VALUES
(
  'fb-1',
  'shop-1',
  'Bean & Brew Cafe',
  'Rohit Deshmukh',
  '+91 98234 56789',
  2,
  'bad',
  'The cold brew took almost 25 minutes to arrive and the AC was leaking near table 4 in the corner.',
  'pending',
  1,
  '2026-10-16T15:20:00.000Z'
),
(
  'fb-2',
  'shop-1',
  'Bean & Brew Cafe',
  'Sneha Rathi',
  '+91 94221 88990',
  3,
  'bad',
  'Coffee quality is great but music volume was way too loud to do laptop work peacefully.',
  'contacted',
  1,
  '2026-10-14T11:45:00.000Z'
),
(
  'fb-3',
  'shop-1',
  'Bean & Brew Cafe',
  'Kunal Tayade',
  '+91 97654 33221',
  1,
  'bad',
  'Garlic bread was cold and waiter forgot our water order twice. Need better staff training.',
  'resolved',
  0,
  '2026-10-10T19:30:00.000Z'
),
(
  'fb-4',
  'shop-2',
  'Glow Unisex Salon & Spa',
  'Priya Kulkarni',
  '+91 94228 12345',
  3,
  'bad',
  'Appointment was booked for 4 PM but had to wait 35 minutes because previous client overran.',
  'contacted',
  1,
  '2026-10-15T18:10:00.000Z'
),
(
  'fb-5',
  'shop-2',
  'Glow Unisex Salon & Spa',
  'Aditya Malpani',
  '+91 98900 54321',
  2,
  'bad',
  'Beard trim was uneven on the right side and stylist was rushing.',
  'resolved',
  1,
  '2026-10-08T14:15:00.000Z'
),
(
  'fb-6',
  'shop-3',
  'Smile Care Advanced Dental Clinic',
  'Vikas Meshram',
  '+91 99234 87654',
  2,
  'bad',
  'Clinic reception staff was a bit dismissive about the insurance pre-authorization form.',
  'pending',
  1,
  '2026-10-12T16:00:00.000Z'
);

-- =========================================================================
-- SEED DATA: POSITIVE 4-5 STAR AI-ASSISTED REVIEWS
-- =========================================================================
INSERT INTO reviews_feedback (
  id, shop_id, shop_name, customer_name, rating,
  review_type, complaint_or_review, selected_tags, language, timestamp
) VALUES
(
  'gr-1',
  'shop-1',
  'Bean & Brew Cafe',
  'Aniket Sharma',
  5,
  'good',
  'Had an outstanding experience at Bean & Brew Cafe in Camp, Amravati! Definitely one of the best spots for best coffee in amravati. The staff is remarkably polite, service was super prompt, and the quality exceeded my expectations. Highly recommended to everyone in Amravati! ⭐⭐⭐⭐⭐',
  '["Best Coffee", "Cozy Ambience", "Polite Staff"]',
  'English',
  '2026-10-17T11:20:00.000Z'
),
(
  'gr-2',
  'shop-1',
  'Bean & Brew Cafe',
  'Pooja Verma',
  5,
  'good',
  'Bean & Brew Cafe (Camp, Amravati) ka experience sach me bohot hi shandaar raha! Cozy Ambience aur staff ka polite nature dil jeet leta hai. Service ekdum fast aur quality top-class. Amravati me definitely must visit place hai! ⭐⭐⭐⭐⭐',
  '["Cozy Ambience", "Fast Wi-Fi"]',
  'Hinglish',
  '2026-10-16T18:40:00.000Z'
),
(
  'gr-3',
  'shop-1',
  'Bean & Brew Cafe',
  'Sanjay Thakare',
  5,
  'good',
  'Camp, Amravati येथील Bean & Brew Cafe ला भेट देऊन खूपच छान अनुभव आला! विशेषतः यांची Best Coffee आणि तत्पर सेवा मनापासून आवडली. अमरावतीत अशी उत्तम सेवा मिळणे खरोखर कौतुकास्पद आहे. नक्की भेट द्या! ⭐⭐⭐⭐⭐',
  '["Best Coffee", "Yummy Pastries"]',
  'Marathi',
  '2026-10-15T09:15:00.000Z'
),
(
  'gr-4',
  'shop-2',
  'Glow Unisex Salon & Spa',
  'Tanvi Gadgil',
  5,
  'good',
  'Got a relaxing hair spa at Glow Unisex Salon in Gadge Nagar, Amravati. The stylists are highly experienced and the ambience is so clean and luxurious! 10/10 recommend!',
  '["Expert Stylists", "Hygienic Place"]',
  'English',
  '2026-10-17T14:10:00.000Z'
),
(
  'gr-5',
  'shop-3',
  'Smile Care Advanced Dental Clinic',
  'Dr. Ramesh Gawande',
  5,
  'good',
  'डॉक्टरांचे मार्गदर्शन आणि उपचारांची पद्धत अतिशय विनम्र व वेदनाविरहित होती. आधुनिक उपकरणे आणि स्वच्छ क्लिनिक. अमरावतीत सर्वोत्तम दंत रुग्णालय!',
  '["Painless Treatment", "Caring Doctor"]',
  'Marathi',
  '2026-10-16T10:30:00.000Z'
);
