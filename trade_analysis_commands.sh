# DATA EXPLORATION


# 1. Show first 5 lines of file
head -5 tradedata.csv

# 2. Count total number of lines
wc -l tradedata.csv

# 3. Count number of columns
head -1 tradedata.csv | awk -F',' '{print NF}'

# 4. Show unique values in column 4
tail -n +2 tradedata.csv | cut -d',' -f4 | sort -u

# 5. Count no. occurences of each unique value in column 4
tail -n +2 tradedata.csv | cut -d',' -f4 | sort | uniq -c

# 6. Count number of unique values in column 4
tail -n +2 tradedata.csv | cut -d',' -f4 | sort -u | wc -l


# DATA CLEANING


# 7. Extract chosen columns and export to new file
cut -d',' -f4,9,11,44 tradedata.csv > cleantradedata.csv

# 8. Show first 5 lines of cleaned data
head -5 cleantradedata.csv

# 9. Check for missing values
grep ",," cleantradedata.csv | wc -l


# EXPLORATIVE ANALYSIS


# 10. Calculate total exports for 2014
awk -F',' '$3 ~ /Export/ && $1 ~ /2014/ {sum+=$4} END {print sum}' cleantradedata.csv

# 11. Calculate total exports for 2024
awk -F',' '$3 ~ /Export/ && $1 ~ /2024/ {sum+=$4} END {print sum}' cleantradedata.csv

# 12. Calculate total imports for 2014
awk -F',' '$3 ~ /Import/ && $1 ~ /2014/ {sum+=$4} END {print sum}' cleantradedata.csv

# 13. Calculate total imports for 2024
awk -F',' '$3 ~ /Import/ && $1 ~ /2024/ {sum+=$4} END {print sum}' cleantradedata.csv

# 14. Top 10 importing countries for 2014 and 2024 by percentage
for year in 2014 2024; do
    echo "$year Imports"
    tr -d '"' < cleantradedata.csv | \
    awk -F',' -v y="$year" '$1==y && $3=="Import" {t+=$4; c[$2]+=$4} END {for(x in c) print c[x]"|"x"|"t}' | \
    sort -t'|' -k1 -rn | head -10 | \
    awk -F'|' '{printf "%2d. %-20s %.2f%%\n", NR, $2, ($1/$3)*100}'
    echo ""
done

# 15. Yearly trade summary (2016-2023)
for year in 2016 2017 2018 2019 2020 2021 2022 2023; do
    exports=$(awk -F',' -v y="$year" '$1 ~ y && $3 ~ /Export/ {sum+=$4} END {print sum}' cleantradedata.csv)
    imports=$(awk -F',' -v y="$year" '$1 ~ y && $3 ~ /Import/ {sum+=$4} END {print sum}' cleantradedata.csv)
    echo "$year - Exports: $exports, Imports: $imports"
done

# 16. Calculate export growth per country (2024 - 2014)
awk -F',' '$3 ~ /Export/ && $1 ~ /2014/ {c14[$2]+=$4} $3 ~ /Export/ && $1 ~ /2024/ {c24[$2]+=$4} END {for(x in c24) print x","(c24[x]-c14[x])}' cleantradedata.csv | sort -t',' -k2 -rn

# 17. Calculate import growth per country (2024 - 2014)
awk -F',' '$3 ~ /Import/ && $1 ~ /2014/ {c14[$2]+=$4} $3 ~ /Import/ && $1 ~ /2024/ {c24[$2]+=$4} END {for(x in c24) print x","(c24[x]-c14[x])}' cleantradedata.csv | sort -t',' -k2 -rn