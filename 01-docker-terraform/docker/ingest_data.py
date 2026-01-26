import pandas as pd
from sqlalchemy import create_engine

def main():
    engine = create_engine('postgresql://root:root@localhost:5432/ny_taxi')
    
    # 1. Ingerindo Zonas (CSV)
    df_zones = pd.read_csv('taxi_zone_lookup.csv')
    df_zones.to_sql(name='zones', con=engine, if_exists='replace', index=False)
    print("Sucesso: Tabela 'zones' criada.")

    # 2. Ingerindo Green Taxi (Parquet - Nov 2025)
    # Parquet já preserva os tipos de data corretamente
    df = pd.read_parquet('green_tripdata_2025-11.parquet')
    
    # Envia tudo para o banco
    df.to_sql(name='green_taxi_data', con=engine, if_exists='replace', chunksize=100000, index=False)
    print(f"Sucesso: {len(df)} linhas de Novembro/2025 ingeridas.")

if __name__ == '__main__':
    main()