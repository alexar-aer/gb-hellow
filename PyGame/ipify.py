import requests
import math
from tqdm import tqdm

# Первым делом, мы получаем внешний IP-адрес
ip = requests.get('https://api.ipify.org').text

# Затем, находим телефонный код региона, используя сервис ip-api.com
response = requests.get(f'http://ip-api.com/json/{ip}', stream=True)
data = response.json()
total_size = int(response.headers.get('content-length', 0))
block_size = 1024
print(f"Dump={math.ceil(total_size//block_size//1024)} MB")
'''

'status':'success'
'country':'Russia'
'countryCode':'RU'
'region':'SPE'
'regionName':'St.-Petersburg'
'city':'St Petersburg'
'zip':'190971'
'lat':59.8983
'lon':30.2618
'timezone':'Europe/Moscow'
'isp':'Rostelecom networks'
'org':'JSC North-West Telecom'
'as':'AS12389 PJSC Rostelecom'
'query':'78.37.233.170'
'''

region_code = data['regionName']

# Выводим результаты
print(f'Ваш внешний IP-адрес: {ip}')
print(f'Телефонный код вашего региона: {region_code}')

with open('regions.json', 'wb') as f:
    for data in tqdm(response.iter_content(block_size), total=math.ceil(total_size//block_size) , unit='KB', unit_scale=True):
        f.write(response.content)
        tqdm.update(len(data))
