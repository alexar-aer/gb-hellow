#stargield.py
'''
    Аналог скринсейвера "сквозь звёзды"
'''
import random

import numpy as np
import pygame
from tqdm import tqdm

# Configs
screen                  = tuple(width = 1500, height = 900)
screen_center           = tuple(x = screen.width // 2, y = screen.height // 2)
screen_max_range        = max(screen_center.x, screen_center.y)
star_default            = tuple(ranges = screen_max_range, colors = 255, pad = 10, cell = 7)

# Pixels array
pixels_max_x            = star_default.ranges // star_default.pad
pixels_max_y            = star_default.ranges // star_default.pad
pixels_filling_perc     = 10                                            # 10% screen filling
pixels_count            = pixels_max_x * pixels_max_y // 100 * pixels_filling_perc
pixels_depth            = 2
pixel_max_bright        = 255
pixel_color_depth       = 1

pixels      = tuple(count = pixels_count, xmax=pixels_max_x, ymax = pixels_max_y, depth = pixels_depth, colors = 1 if pixel_color_depth == 1 else 3)
starfield   = np.zeros((pixels.count, pixels.depth, pixels.colors))

# Common utils

def rnd(end=1, start=0):
    return random.randint(start, end)


def get_random_color(color_depth = pixel_color_depth):
    try:
        if color_depth == 0:                    # black/white
            randcolor = pixel_max_bright if rnd() == 1 else 0
            return (randcolor, randcolor, randcolor)
        elif color_depth == 1:                  # generate 1 of 3 colors
            randindex = rnd(2)
            r = rnd(pixel_max_bright) if randindex == 0 else 0
            g = rnd(pixel_max_bright) if randindex == 1 else 0
            b = rnd(pixel_max_bright) if randindex == 2 else 0
            return (r, g, b)
        elif color_depth == 2:                  # generate 2 of 3 colors
            randindex = rnd(2)
            r = 0 if randindex == 0 else rnd(pixel_max_bright)
            g = 0 if randindex == 1 else rnd(pixel_max_bright)
            b = 0 if randindex == 2 else rnd(pixel_max_bright)
            return (r, g, b)
        elif color_depth == 3:                  # generate full color
            g = rnd(pixel_max_bright)
            r = rnd(pixel_max_bright)
            b = rnd(pixel_max_bright)
            return (r, g, b)
        else:
            raise ValueError(f'Error get_random_color: invalid color depth={color_depth}!')

    except:                                     # white color
        return (pixel_max_bright, pixel_max_bright, pixel_max_bright)


# Initializations
progress = tqdm(total=pixels_count*pixels_depth, desc='Generate pixels', ascii=True)

for i in range(pixels_count):
    for z in range(pixels_depth):
        x = rnd(pixels_max_x)
        y = rnd(pixels_height)
        starfield[x,y,z] = get_random_color()


    if (pixel_count % 50 == 0): progress.update(50)


progress.close()
print(starfield)
print(starfield[pixels_max_x-1,pixels_height-1,pixels_depth-1])
print(starfield[0,0,0])


# Инициализация pygame
pygame.init()

screen = pygame.display.set_mode((screen_width, screen_height))

# Основной цикл программы
running = True
while running:
    # Обработка событий
    for event in pygame.event.get():
        if event.type == pygame.QUIT:
            running = False

    # Отображение пикселей на экране

    for x in range(pixels_max_x):
        for y in range(pixels_height):
            #for z in range(depth):
                color = starfield[x][y][0]
                pygame.draw.rect(screen, color, (x*star_pad, y*star_pad, star_cell, star_cell))

        randcolor = random.randint(0, star_colors)
        color = (randcolor,randcolor,randcolor)

        i = rnd(pixels_max_x)
        j = rnd(pixels_height)
        starfield[i,j,0] = color

    # Обновление экрана
    pygame.display.flip()
    #print(f'next {i}x{j}.')

# Завершение работы pygame
pygame.quit()
print('\nALL Done.')
