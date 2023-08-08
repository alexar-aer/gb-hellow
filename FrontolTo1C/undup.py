# undup.py
'''
    Utility for copying unique lines from INPUT into OUTPUT
'''
import csv
import os
from tqdm import tqdm

input_file_name         = "report_.csv"         # SOURCE FILE
undup_file_name         = "report0.csv"         # WORK (undupled) FILE

header_count            = 3                     # count Header lines + '\n{#smen}'
header_lines            = ''                    # Strings for insert into all result files.

unique_lines            = set()                 # Creating a set to store unique strings
lines_count             = 0                     # Counter of processed rows

current_folder = os.getcwd()                    # Checking current work dir
script_folder = os.path.dirname(os.path.abspath(__file__))
if current_folder != script_folder: os.chdir(script_folder) # Change to script root folder

print(f'Open source file: {input_file_name}...') # Counting lines in SOURCE
with open(input_file_name, 'r') as input_file:
    total_lines_count = sum(1 for _ in input_file)

print(f'Source file total: {total_lines_count} lines.')
progress = tqdm(total = total_lines_count, leave = False, unit = ' lines',
                desc = f'Searching for unique lines...') # Create ProgressBar

with open(input_file_name, 'r') as input_file:
    for line in input_file:
        lines_count += 1
        if (lines_count < header_count):        # Save header -1 last line! (Nom.shift)
            header_lines += line

        unique_lines.add(line.strip())          # Adding a string to a set of uniques
        progress.update(1)

print(f'\nProcessed: {lines_count} lines')
unique_lines_count = len(unique_lines)          # Number of unique rows
print(f'Unique: {unique_lines_count} lines')
print('Header:')
print(header_lines, end='')
print('==================')

progress.desc = f'Copying unique lines...'      # Rename ProgressBar
lines_count = 0                                 # Reset counter and ProgressBar
progress.reset()
progress.total = unique_lines_count

# Открываем новый файл для записи
with open(undup_file_name, 'w') as output_file:
    with open(input_file_name, 'r') as input_file:
        for line in input_file:
            curr_line = line.strip()
            if curr_line in unique_lines:       # Проверяем, является ли строка уникальной
                lines_count += 1
                output_file.write(line)         # Записываем уникальную строку в новый файл
                unique_lines.remove(curr_line)  # Удаляем строку из множества уникальных строк
                progress.update(1)
#//with open
progress.close()
print(f'Done copying unique {lines_count} lines into {undup_file_name}.')
