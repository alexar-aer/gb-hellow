# undup.py
'''Script for copying from INPUT unique lines into OUTPUT
'''
import csv
import os

input_file_name = "report.csv"
output_file_name = "report0.csv"

# Создаем множество для хранения уникальных строк
unique_lines = set()
line_count = 0

# Открываем исходный файл для чтения
with open(input_file_name, 'r') as input_file:
    # Первый проход по исходному файлу
    for line in input_file:
        line_count += 1
        # Добавляем строку в множество уникальных строк
        unique_lines.add(line.strip()) # .split(';')[0])


print(f'\nCount:{line_count} lines')
print(f'Unique:{len(unique_lines)} lines')
line_count = 0

# Открываем новый файл для записи
with open(output_file_name, 'w') as output_file:
    # Второй проход по исходному файлу
    with open(input_file_name, 'r') as input_file:
        for line in input_file:
            # Проверяем, является ли строка уникальной
            curr_line = line.strip()
            if curr_line in unique_lines:
                line_count += 1
                # Записываем уникальную строку в новый файл
                output_file.write(line)
                # Удаляем строку из множества уникальных строк
                unique_lines.remove(curr_line)
