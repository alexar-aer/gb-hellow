# run.py
'''
Utility for removing duplicates in a file "REPORT.CSV" by Frontol-6 and xPOS-3 and
copying its parts to subfolders, by dates and numbers of cash shifts (z-reports)
from source CSV-lines ("\output\YYYY\MMDD_Smena\report.csv")
'''
import csv
import os
from datetime import datetime
from tqdm import tqdm

input_file_name         = "report.csv"          # SOURCE FILE
undup_file_name         = "undupled.csv"        # WORK (undupled) FILE
output_folder           = 'output'              # OUTPUT FOLDER
output_file_name        = 'report.rep'          # RESULT FILE

header_count            = 2                     # count Header lines + '\n{#smen}'
header_line             = ''                    # Strings for insert into all result files.

smene_col               = 13                    # Frontol6 field of Num.shifts ака № смены
date_col                = 02                    # Frontol6 field of DATE
cheque_code_col         = 03                    # Frontol6 field of transaction codes
zreport_cheque_code     = 63                    # Frontol6 transaction code of Z-reports


print('Программа для помощи при обработке больших кассовых отчётов на слабых компах')
print(f'Берёт исходный файл {input_file_name}, удаляет дубли и сохраняет в {undup_file_name}')
print(f'Далее, из {undup_file_name} создаёт подпапки исходя из года и месяца каждой строки, и пишет их в \{output_folder}\{output_file_name}.')

# УДАЛЕНИЕ ДУБЛИКАТОВ

# Создаем множество для хранения уникальных строк
unique_lines = set()
line_count = 0 # счётчик обработанных строк

with open(input_file_name, 'r') as input_file:
    total_lines_count = sum(1 for _ in input_file)

# Открываем исходный файл для чтения
print(f'Source file: {input_file_name} length:{total_lines_count}...')
progress = tqdm(total=total_lines_count, desc=f'Searching for unique lines...')  # Создание прогрессбара с общим количеством шагов

# Первый проход по исходному файлу
with open(input_file_name, 'r') as input_file:
    for line in input_file:
        line_count += 1
        if (line_count <= header_count): header_line += line # Save header    next(reader)  # Skip header row
        # Добавляем строку в множество уникальных строк
        unique_lines.add(line.strip()) # .split(';')[0])
        progress.update(1)

progress.close()
print('Header:')
print(header_line, end='')
print('==================')
print(f'\nCount:{line_count} lines')

unique_lines_count = len(unique_lines)  # число уникальных строк
print(f'Unique:{unique_lines_count} lines')
progress = tqdm(total=unique_lines_count, desc=f'Copying unique lines...')  # Создание прогрессбара с общим количеством шагов

# Открываем новый файл для записи
with open(undup_file_name, 'w') as output_file:
    # Второй проход по исходному файлу
    with open(input_file_name, 'r') as input_file:
        line_count = 0 # сбрасываем счётчик
        for line in input_file:
            # Проверяем, является ли строка уникальной
            curr_line = line.strip()
            if curr_line in unique_lines:
                line_count += 1
                # Записываем уникальную строку в новый файл
                output_file.write(line)
                # Удаляем строку из множества уникальных строк
                unique_lines.remove(curr_line)
                progress.update(1)


progress.close()
print(f'Done copying unique {line_count} lines to {undup_file_name}.')

# Разделение исходного файла в подпапки по годам и месяцам
year = 0
month = 0
day = 0
print(f'Open source CSV: {undup_file_name}...')
progress = tqdm(total=line_count, desc=f'Create {output_folder}\{year}\{month}{day} subfolders...')  # Создание прогрессбара с общим количеством шагов

with open(undup_file_name, 'r') as file:
    last_year = 0
    last_month = 0
    last_day = 0
    last_smena = 0

    line_count = 0
    years_monts = set()
    reader = csv.reader(file, delimiter=';')

    for i in range(header_count):
        next(reader)  # Skip header row

    for row in reader:
        line_count += 1
        date_str = row[1]
        date = datetime.strptime(date_str, "%d.%m.%Y")
        year = date.year
        month = date.month
        day = date.day
        smena_str = row[13]#номер текущей смены
        smena = int(smena_str) if smena_str.isdigit() else 0

        year_str = f"{str(year).zfill(4)}\{str(month).zfill(2)}{str(day).zfill(2)}_{str(smena).zfill(4)}"
        years_monts.add(year_str)

        folder_path = os.path.join(output_folder, year_str)
        os.makedirs(folder_path, exist_ok=True)
        content = row[:]
        file_path = os.path.join(folder_path, output_file_name)

        with open(file_path, 'a', encoding='utf-8') as output_file:
            if last_year != year:
                last_year = year
                last_month = 0
                last_day = 0
                last_smena = 0

            if last_month != month:
                last_month = month
                last_day = 0
                last_smena = 0

            if last_day != day:
                last_day = day
                last_smena = smena
                output_file.write(header_line)#write header

            if last_smena != smena:
                last_day = day
                output_file.write(header_line)  # write header
                output_file.write(f'{smena}\n') # write header
                last_smena = smena

            output_file.write(';'.join(row))
            output_file.write('\n')
            progress.desc = f'Create {output_folder}\{year_str} subfolders...'
            progress.update(1)

progress.close()
print(f'Created {len(years_monts)} folders.')
print(f'ALL Done {line_count} lines.')
