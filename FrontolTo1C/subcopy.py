# subcopy.py
'''
    Utility for splitting the source file into subfolders by year, month, and cash shift
'''
import csv
import os
from datetime import datetime
from tqdm import tqdm

def lz(v, zfills = 2): return str(v).zfill(zfills) # LeadingZero

def s2i(s = '', default = 0): return int(s) if s.isdigit() else default

undup_file_name         = "report1.csv"         # WORK (undupled) FILE
output_folder           = 'output1'             # OUTPUT FOLDER
output_file_name        = 'report.csv'          # RESULT FILE

header_count            = 3                     # Count Header lines for SKIPPING
header_lines            = f'#\n1\n'             # Strings for insert into all result files.

date_col                = 1                     # Frontol6 field of DATE
smene_col               = 13                    # Frontol6 field of Num.shifts ака № смены

current_folder = os.getcwd()                    # Checking current work dir
script_folder = os.path.dirname(os.path.abspath(__file__))
if current_folder != script_folder: os.chdir(script_folder) # Move to script root folder

print(f'Open source CSV: {undup_file_name}...')
with open(undup_file_name, 'r') as input_file:  # Counting lines in SOURCE
    total_lines_count = sum(1 for _ in input_file)

progress = tqdm(total = total_lines_count, leave = False, unit = ' lines', \
                desc = f'Create Output folders...') # Create ProgressBar TQDM

with open(undup_file_name, 'r') as source_file:
    lines_count         = 0
    last_folder         = ''                    # Checking the creation of a new subfolder
    folders             = set()                 # Set for counting created subfolders
    reader              = csv.reader(source_file, delimiter = ';')  # CSV reader
    for i in range(header_count): next(reader)  # Skip header rows

    for row in reader:
        lines_count += 1
        date_str        = row[date_col]
        date            = datetime.strptime(date_str, "%d.%m.%Y")
        year            = date.year
        month           = date.month
        day             = date.day
        smene           = s2i(row[smene_col])   # Number of the current cash shift

        # Format folder_str: YYYY\MMDD_SSSS (S = Num.cash shifts)
        folder_str      = str(f'{lz(year, 4)}\{lz(month)}{lz(day)}_{lz(smene, 4)}')
        folders.add(folder_str)

        folder_path     = os.path.join(output_folder, folder_str)
        os.makedirs(folder_path, exist_ok=True)
        file_path       = os.path.join(folder_path, output_file_name)

        with open(file_path, 'a', encoding='utf-8') as output_file:
            if last_folder != folder_str:       # NEW subfolder and RESULT file
                last_folder = folder_str
                output_file.write(header_lines) # write header
                output_file.write(f'{smene}\n') # write Num.cash shift

            content     = ';'.join(row) + '\n'  # Join line by ';'
            output_file.write(content)
            progress.desc = f'Create {folder_path} subfolder...'
            progress.update(1)

progress.close()
print(f'Done {lines_count} lines. Created {len(folders)} folders.')
