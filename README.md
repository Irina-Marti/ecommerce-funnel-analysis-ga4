# Ecommerce Conversion Funnel Analysis (GA4 Dataset)

## 📌 Project Overview
This project focuses on analyzing the user journey and conversion funnel for an e-commerce website using raw data from **Google Analytics 4 (GA4)**. The goal was to build an interactive dashboard that helps the marketing team identify drop-off points and optimize traffic sources.



---

**Key results:**
* Built a 7-step conversion funnel from session start to purchase.
* Enabled deep-dive analysis by traffic source, device category, and landing pages.
* Processed raw big data using advanced SQL techniques in BigQuery.

---

## 🛠 Tech Stack
* **SQL (BigQuery):** Data extraction, unnesting repeated fields, and business logic implementation.
* **Tableau:** Data visualization and interactive dashboard design.
* **Google Cloud Platform:** Work with public ecommerce datasets.

---

## 📊 The Funnel Stages
The analysis tracks users through the following 7 stages:
1. Session Start
2. View Item
3. Add to Cart
4. Begin Checkout
5. Add Shipping Info
6. Add Payment Info
7. Purchase

---

## 📈 Dashboard Key Features
* **Interactive Funnel Visualization:** Visual representation of user drop-offs at each stage.
* **Dynamic Filters:** Filter data by Date, Traffic Source (Source/Medium), Device Category, OS, and Language.
* **KPI Overview:** High-level metrics for sessions, orders, and overall conversion rates.

🔗 **[View Live Dashboard on Tableau Public](https://public.tableau.com/app/profile/iryna.martynenko/viz/ProjectEcommerceFunnel_17725848175730/EcommerceConversionFunnelDashboard)**

---

## 💻 SQL Implementation
The data was sourced from the `bigquery-public-data.ga4_obfuscated_sample_ecommerce` dataset.
The SQL script handles:
* **Unnesting** of event parameters and user properties.
* **CTEs** for modular and readable query structure.
* **Event-based logic** to define unique sessions per funnel step.

🔗 **[View SQL Script](ga4_funnel_analysis.sql)**

---

## 💡 Key Insights
* The most significant drop-off occurs between first and second stages: **Session Start** and **View Item**.
* Although most traffic comes from Google, its conversion rate is lower than some other sources.
* Mobile users show a higher conversion rate compared to Desctop users (1,38% and 1,31%).
