"""@bruin

name: ingestion.trips
connection: duckdb-default

materialization:
  type: table
  strategy: append
image: python:3.12

@bruin"""

import json
import os
from datetime import datetime, timedelta
import pandas as pd
import pyarrow.parquet as pq
import requests
from io import BytesIO


def materialize():
    """
    Fetch NYC Taxi trip data from the TLC public endpoint for the specified date range and taxi types.
    
    Uses Bruin runtime context:
    - BRUIN_START_DATE / BRUIN_END_DATE: Date range for data extraction
    - BRUIN_VARS: Pipeline variables containing taxi_types
    
    Returns a DataFrame with raw trip data from the TLC endpoint.
    """
    # Get date range from Bruin context
    start_date_str = os.getenv("BRUIN_START_DATE", "2025-01-01")
    end_date_str = os.getenv("BRUIN_END_DATE", "2025-01-01")
    
    start_date = datetime.strptime(start_date_str, "%Y-%m-%d")
    end_date = datetime.strptime(end_date_str, "%Y-%m-%d")
    
    # Get taxi types from pipeline variables
    bruin_vars_str = os.getenv("BRUIN_VARS", '{"taxi_types": ["yellow"]}')
    bruin_vars = json.loads(bruin_vars_str)
    taxi_types = bruin_vars.get("taxi_types", ["yellow"])
    
    # Generate list of (year, month, taxi_type) tuples for the date range
    current_date = start_date
    #dates_to_fetch = []
    
    # Force apenas o mês de início para evitar que o loop saia do controle
    dates_to_fetch = [(start_date.year, start_date.month)]
    
    # Comente ou delete o 'while current_date <= end_date:'
    #while current_date <= end_date:
    dates_to_fetch.append((current_date.year, current_date.month))
    
    # Move to first day of next month
    if current_date.month == 12:
        current_date = current_date.replace(year=current_date.year + 1, month=1)
    else:
        current_date = current_date.replace(month=current_date.month + 1)
    
    # Fetch data for each taxi type and month combination
    all_data = []
    base_url = "https://d37ci6vzurychx.cloudfront.net/trip-data"
    extraction_time = datetime.utcnow().isoformat()
    
    for taxi_type in taxi_types:
        for year, month in dates_to_fetch:
            # Construct the file URL
            filename = f"{taxi_type}_tripdata_{year:04d}-{month:02d}.parquet"
            url = f"{base_url}/{filename}"
            
            try:
                print(f"Fetching {url}...")
                response = requests.get(url, timeout=30)
                response.raise_for_status()

                # Lista de colunas estritamente necessárias
                columns_to_load = [
                    "VendorID", 
                    "tpep_pickup_datetime", 
                    "tpep_dropoff_datetime", 
                    "passenger_count", 
                    "trip_distance", 
                    "RatecodeID",
                    "fare_amount", 
                    "tip_amount", 
                    "total_amount"
                ]
                
                # Read parquet file from bytes with specific columns
                df = pd.read_parquet(BytesIO(response.content), columns=columns_to_load)
                
                # Read parquet file from bytes
                # df = pd.read_parquet(BytesIO(response.content))
                
                # Add metadata columns for lineage
                df["extracted_at"] = extraction_time
                df["taxi_type"] = taxi_type
                
                all_data.append(df)
                print(f"  ✓ Loaded {len(df)} rows")
                
            except requests.exceptions.HTTPError as e:
                if response.status_code == 404:
                    print(f"  ⚠ File not found (404): {filename}")
                else:
                    print(f"  ✗ HTTP error: {e}")
            except Exception as e:
                print(f"  ✗ Error fetching {filename}: {e}")
    
    # Combine all DataFrames
    if all_data:
        final_df = pd.concat(all_data, ignore_index=True)
        print(f"\nTotal rows fetched: {len(final_df)}")
        return final_df
    else:
        print("No data fetched. Returning empty DataFrame.")
        return pd.DataFrame()
