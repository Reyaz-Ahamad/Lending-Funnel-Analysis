# Lending Funnel Analysis

## 📌 Project Overview

This project focuses on analyzing the **Lending funnel** using **SQL Server** to track customer progression from registration to loan disbursal.

The objective of this analysis is to understand **funnel performance, stage-wise conversion rates, daily trends, approval performance, and disbursal performance**.

The analysis transforms raw lending data into a structured **daily MIS funnel report** that can be used by business and operations teams for performance monitoring and decision-making.

---

## 🎯 Business Objective

The primary objectives of this project are:

- **Track customer movement** through different stages of the lending funnel.
- Measure **daily customer volumes** at each funnel stage.
- Calculate **stage-wise conversion percentages**.
- Identify potential **funnel drop-offs** between different stages.
- Track **Approval and Disbursal performance**.
- Compare **daily performance with MTD performance**.
- Create a structured dataset that can be used for **MIS reporting and dashboards**.
- Reduce manual reporting effort by creating a **SQL-based automated reporting logic**.

---

## 🔄 Lending Funnel

The project follows the below customer journey:

```text
Registration
     ↓
KYC Completed
     ↓
Information Given
     ↓
Documents Given
     ↓
Decision Taken
     ↓
Approval
     ↓
Disbursal
