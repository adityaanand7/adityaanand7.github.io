import csv
import os
import sys

if len(sys.argv) != 3:
    print("Usage: python generate_folders.py <input_csv> <output_directory>")
    sys.exit(1)

csv_file = sys.argv[1]
output_dir = sys.argv[2]

NAME_COL = "Full name"
ID_COL = "Identifier"  

os.makedirs(output_dir, exist_ok=True)

with open(csv_file, newline='', encoding='utf-8-sig') as csvfile:
    reader = csv.DictReader(csvfile)

    print("Detected columns:", reader.fieldnames)

    if NAME_COL not in reader.fieldnames or ID_COL not in reader.fieldnames:
        print("ERROR: Required columns not found.")
        sys.exit(1)

    for row in reader:
        name = row[NAME_COL].strip()

        identifier = row[ID_COL].strip()
        id_number = identifier.split()[-1]

        folder_name = f"{name}_{id_number}_assignsubmission_file"
        folder_path = os.path.join(output_dir, folder_name)

        os.makedirs(folder_path, exist_ok=True)
        print(f"Created: {folder_path}")

