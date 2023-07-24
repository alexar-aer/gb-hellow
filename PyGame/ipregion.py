import requests
import tqdm as tqdm
import math

def get_ip_info():
    ip_address = requests.get('https://api.ipify.org').text

    ip_info = requests.get(f'https://ipinfo.io/{ip_address}').json()

    print(f"IP Address: {ip_address}")
    print(f"Region: {ip_info['region']}")
    country = ip_info['country']
    print(f"Страна: {country}" )

    response = requests.get(url = "https://dumps.wikimedia.org/ruwiki/latest/ruwiki-latest-pages-articles.xml.bz2", stream=True)
    total_size = int(response.headers.get('content-length', 0))
    block_size = 1024
    print(f"WikiDump={math.ceil(total_size//block_size//1024)} MB")

    # with open('ruwiki.xml.bz2', 'wb') as f:
    #     for data in tqdm(response.iter_content(block_size), total=math.ceil(total_size//block_size) , unit='MB', unit_scale=True):
    #         f.write(response.content)

if __name__ == '__main__':

    get_ip_info()
    print("Done.")
