# ODC_Airbnb_Analysis_Hackathon
This project demonstrates a full-cycle Airbnb Data Analysis focused on European cities. It covers the entire pipeline from raw data exploration to advanced insights, using modern data engineering and machine learning practices.

---
## 📌 Project Overview 
This project was developed during the **ODC Hackathon** to showcase: 
- End-to-end data pipeline design
- Exploratory Data Analysis (EDA)
- SQL-based data warehouse modeling
- Insightful dashboards for stakeholders

---
## 🚀 Features
- **Data Cleaning & Preprocessing**: Handling missing values, feature engineering.
- **Exploratory Analysis**: Trends in pricing, occupancy, and location-based insights.
- **Web scraping**: Increase Airbnb data with new features.
- **SQL Warehouse Layer**: Structured queries for scalable analytics.
- **ML Model**: Regression model for price prediction.
- **Visualization**: Clear charts and dashboards for decision-making.

---
## 🏗️ Data Architecture

The data architecture for this project follows Medallion Architecture **Bronze**, **Silver**, and **Gold** layers:
<img width="1113" height="682" alt="High_Level_Architecture" src="https://github.com/user-attachments/assets/5076fc8e-d9f4-455d-bcc9-f0bd61fbedcb" />

1. **Bronze Layer**: Stores raw data as-is from the source systems. Data is ingested from CSV Files into SQL Server Database.
2. **Silver Layer**: This layer includes data cleansing, standardization, and normalization processes to prepare data for analysis.
3. **Gold Layer**: Houses business-ready data modeled into a star schema required for reporting and analytics.


# BI: Analytics & Reporting (Data Analysis) 
### Overview Analysis
<img width="1310" height="738" alt="Screenshot 2026-02-07 164758" src="https://github.com/user-attachments/assets/e42f7d8f-47e1-4693-9fbd-f31c5caa5afb" />

### Rental Performance in Europen Cities
<img width="1315" height="733" alt="Screenshot 2026-02-07 164820" src="https://github.com/user-attachments/assets/9ba72739-07ac-4a91-9e53-25d8c50b41de" />

### Key Influencers 
for checking what influences guest_satisfaction_score & Price
<img width="1315" height="740" alt="Screenshot 2026-02-07 164838" src="https://github.com/user-attachments/assets/21f8d5cb-9dbd-4b2a-94a2-698804c107c0" />

## ✨Key Insights
- London is the top-performing city in rentals and revenue.
- Cleanliness is the most important factor for guest satisfaction.
- City-center properties attract the most bookings.
- Weekend demand is higher than weekdays.
- Prices depend on quality of life, safety, and economic strength.
- The market is dominated by mid-range listings.


## 🛡️ License

This project is licensed under the [MIT License](LICENSE). You are free to use, modify, and share this project with proper attribution.

## 🌟 About Me

Hi there! I'm **Mohamed Hesham**. I’m an Business Intelligence Developer and Data Analyst 

Let's stay in touch! Feel free to connect with me on the following platforms:

[![LinkedIn](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://linkedin.com/in/moohamed-hesham)
[![Gmail](https://img.shields.io/badge/Gmail-Email_Me-D14836?style=for-the-badge&logo=gmail&logoColor=white)](mailto:mh2813769@gmail.com)
[![Portfolio](https://img.shields.io/badge/Portfolio-Visit_My_Site-0A66C2?style=for-the-badge&logo=About.me&logoColor=white)](https://mohamed-hesham-portfolio.lovable.app)
