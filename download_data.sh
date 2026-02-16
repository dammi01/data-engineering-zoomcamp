#!/usr/bin/env zsh

# Cria a pasta e entra nela
mkdir -p ~/Projects/data-engineering-zoomcamp/03-data-warehouse/homework
cd ~/Projects/data-engineering-zoomcamp/03-data-warehouse/homework

# Baixa os 6 meses de 2024 (ou quantos estiverem disponíveis)
URL_BASE="https://d37ci6vzurychx.cloudfront.net/trip-data"
for month in {01..06}; do
  echo "Baixando mês ${month} via IPv4..."
  # Forçando IPv4 explicitamente conforme diretrizes
  # A flag -4 resolve o erro 443 de conexão IPv6
  wget -4 -N "${URL_BASE}/yellow_tripdata_2024-${month}.parquet"
done



