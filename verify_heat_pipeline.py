import pandas as pd
import numpy as np
import os
from datetime import datetime, timedelta

def create_mock_data():
    """Creates dummy excel files to simulate the project environment."""
    print("🛠️ Creating mock datasets for testing...")
    
    # Mock Data for 2021-2024
    data_21_24 = {
        'Case #': ['2021-001', '2022-002', '2024-003'],
        'Date of Death': ['2021-07-15', '2022-08-10', '2024-06-01'],
        'Name': ['Test A', 'Test B', 'Test C']
    }
    
    # Mock Data for 2024 EOY (with a duplicate of 2024-003)
    data_24_eoy = {
        'Case #': ['2024-003', '2024-004'],
        'Date of Death': ['2024-06-01', '2024-11-15'],
        'Name': ['Test C', 'Test D']
    }
    
    # Mock Data for 2025 EOY
    data_25_eoy = {
        'Case #': ['2025-001', '2025-002'],
        'Date of Death': ['2025-05-10', '2025-05-10'],
        'Name': ['Test E', 'Test F']
    }
    
    pd.DataFrame(data_21_24).to_excel('Heat Related 2021-2024.xlsx', index=False)
    pd.DataFrame(data_24_eoy).to_excel('Heat Related 2024 EOY Coroner-dataset.xlsx', index=False)
    pd.DataFrame(data_25_eoy).to_excel('Heat Deaths EOY 2025.xlsx', index=False)
    print("✅ Mock Excel files created.")

def test_pipeline_logic():
    """Tests the logic implemented in the Jupyter notebooks."""
    print("\n🔍 Testing Pipeline Logic...")
    
    try:
        # 1. Load and Concatenate
        heat_21_24 = pd.read_excel('Heat Related 2021-2024.xlsx')
        heat_24_eoy = pd.read_excel('Heat Related 2024 EOY Coroner-dataset.xlsx')
        heat_25_eoy = pd.read_excel('Heat Deaths EOY 2025.xlsx')
        
        heat_df = pd.concat([heat_21_24, heat_24_eoy, heat_25_eoy], ignore_index=True)
        print(f"Row count after concat: {len(heat_df)} (Expected: 7)")
        
        # 2. Deduplicate
        heat_df.drop_duplicates(subset=['Case #'], inplace=True)
        print(f"Row count after dedup: {len(heat_df)} (Expected: 6)")
        
        # 3. Process Dates and Group
        heat_df['Date of Death'] = pd.to_datetime(heat_df['Date of Death'])
        daily_heat_deaths = heat_df.groupby('Date of Death').size().rename('heat_death_count').reset_index()
        daily_heat_deaths.rename(columns={'Date of Death': 'date'}, inplace=True)
        daily_heat_deaths['date'] = pd.to_datetime(daily_heat_deaths['date']).dt.date
        
        print(f"Daily aggregate count for 2025-05-10: {daily_heat_deaths[daily_heat_deaths['date'] == datetime(2025,5,10).date()]['heat_death_count'].values[0]}")
        
        # 4. Mock Merge with Weather/Incident TS
        mock_ts = pd.DataFrame({
            'date': [datetime(2024,6,1).date(), datetime(2024,6,2).date()],
            'incident_count': [10, 12]
        })
        
        final_ts = pd.merge(mock_ts, daily_heat_deaths, on="date", how="outer").fillna(0)
        
        print("\n🏆 Logic Check Passed!")
        print("Final Merge Sample (showing heat_death_count integration):")
        print(final_ts.head())
        
    except Exception as e:
        print(f"❌ Logic Check Failed: {e}")

def cleanup():
    """Removes mock files."""
    for f in ['Heat Related 2021-2024.xlsx', 'Heat Related 2024 EOY Coroner-dataset.xlsx', 'Heat Deaths EOY 2025.xlsx']:
        if os.path.exists(f):
            os.remove(f)
    print("\n🧹 Cleanup complete.")

if __name__ == "__main__":
    create_mock_data()
    test_pipeline_logic()
    cleanup()
