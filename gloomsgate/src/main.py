#!/usr/bin/env python3

import pygame
from pygame._sdl2.video import Window, Renderer, Texture, Image
import sys
from engine import *
from settings import *
from math import ceil, floor


pygame.init()
clock = pygame.time.Clock()
font_billy_regular = pygame.font.Font("assets/billy/Billy-Regular.ttf", 20)

class Game:
	def __init__(self):
		self.state = "menu"
		self.running = True

class WindowHandler:
	def __init__(self, size, vsync=0):
		self.window = Window(title="Gloomsgate", size=(size[0]*SCALE_CONST, size[1]*SCALE_CONST))
		self.window.resizable = True
		self.renderer = Renderer(self.window, vsync=vsync)
		self.size = size
		self.width, self.height = self.size
		self.center = [s // 2 for s in size]
		self.renderer.scale = (SCALE_CONST, SCALE_CONST)


class Corbin(Entity):
	def __init__(self):
		self.texs, self.rects = load_tex('assets/player-run.png', win.renderer, 8)
		super().__init__()
		self.x_pos = win.center[0] - self.width / 2
		self.y_pos = win.center[1] - self.height / 2
		self.x_vel = 2
		self.y_vel = 2
		self.anim = 0
		self.should_move = False
		self.hp = 5

	def update(self):
		self.base_update(win, self.x_pos, self.y_pos, True)
		if self.should_move:
			self.wasd(self.x_vel, self.y_vel)


class Menu(Entity):
	def __init__(self):
		self.x_pos = -440
		self.y_pos = 0
		self.x_vel = 0.1
		self.tex, self.rect = load_tex('assets/menu-wall.png', win.renderer, 1, 0.75)

	def update(self):
		self.x_pos += self.x_vel
		self.base_update(win, self.x_pos, self.y_pos, False)

game = Game()
win = WindowHandler((WIN_WIDTH, WIN_HEIGHT), 1)
menu = Menu()
corbin = Corbin()
grass_1 = Block((0, 0), "grass-1", win)
heart_texs, heart_rects = load_tex(f'assets/heart.png', win.renderer, 2)
heart_rect = heart_rects[0]
heart_tex = heart_texs[0]
heart_rect.move_ip(16, 16)

menu_buttons = [
		LinkButton("Play", (win.width/15, win.height/2 + 24*1), 2*[font_sizes["subtitle"]], font_billy_regular, (255, 255, 255, 255), win.renderer, lambda: set_state(game, "gameplay")),
		LinkButton("Settings", (win.width/15, win.height/2 + 24*2), 2*[font_sizes["subtitle"]], font_billy_regular, (255, 255, 255, 255), win.renderer, lambda: set_state(game, "settings")),
		LinkButton("Skins", (win.width/15, win.height/2 + 24*3), 2*[font_sizes["subtitle"]], font_billy_regular, (255, 255, 255, 255), win.renderer, lambda: set_state(game, "skins")),
		LinkButton("Credits", (win.width/15, win.height/2 + 24*4), 2*[font_sizes["subtitle"]], font_billy_regular, (255, 255, 255, 255), win.renderer, lambda: set_state(game, "credits")),
]

while game.running:
    for event in pygame.event.get():
        for menu_button in menu_buttons:
            menu_button.process_event(event)
            if event.type == pygame.QUIT:
                quit(game.running)
        if event.type == pygame.KEYDOWN:
            if event.key == pygame.K_SPACE:
                corbin.hp -= 0.5
        if event.type == pygame.VIDEORESIZE:
            USER_SCALE_CONST = event.w / WIN_WIDTH
        win.renderer.scale = 2*[USER_SCALE_CONST * SCALE_CONST]

    fill_rect(win.renderer, (0, 0, *win.size), (0, 0, 0, 255))

    if game.state == "menu":
        menu.update()
        for menu_button in menu_buttons:
            menu_button.update(win)

    if game.state == "gameplay":
        grass_1.update(win, (corbin.x_vel, corbin.y_vel))
        corbin.update()
        for x in range(ceil(corbin.hp)):
            rect = heart_rect.move(18 * x, 0)
        if floor(corbin.hp) == corbin.hp or x != floor(corbin.hp):
            tex = heart_texs[0]
        else:
            tex = heart_texs[1]
        win.renderer.blit(tex, rect)

    win.renderer.present()
