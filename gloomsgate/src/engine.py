import pygame
from pygame._sdl2.video import Window, Renderer, Texture, Image
import sys
from settings import *

font_sizes = {
	"body":	 FONT_SIZE,
	"subtitle": FONT_SIZE*2,
	"title": FONT_SIZE*3
}

def set_state(game, target_state):
	game.state = target_state
# print(game.state)


def get_mouse_pos():
	return [pos/SCALE_CONST for pos in pygame.mouse.get_pos()]


def load_tex(path, renderer, frames=1, scale_factor=1):
	if frames > 1:
		surf = pygame.transform.scale_by(pygame.image.load(path), scale_factor)
		frame_width = surf.get_width() / frames
		frame_height = surf.get_height()
		texs = [Texture.from_surface(renderer, surf.subsurface(x * frame_width, 0, frame_width, frame_height)) for x in range(frames)]
		rects = [tex.get_rect() for tex in texs]
		return texs, rects
	else:
		surf = pygame.transform.scale_by(pygame.image.load(path), scale_factor)
		tex = Texture.from_surface(renderer, surf)
		rect = tex.get_rect()
		return tex, rect


def fill_rect(renderer, rect, color):
	renderer.draw_color = color
	renderer.fill_rect(rect)


def quit(running):
	running = False
	pygame.quit()
	sys.exit()


class LinkButton:
	def __init__(self, text, pos, size, font, color, renderer, command):
		self.surf = font.render(text, True, color)
		self.tex = Texture.from_surface(renderer, self.surf)
		self.tex.update(self.surf)
		self.rect = self.tex.get_rect()
		self.rect.x, self.rect.y = pos
		self.command = command

	def update(self, win):
		win.renderer.blit(self.tex, self.rect)

	def process_event(self, event):
		if event.type == pygame.MOUSEBUTTONDOWN:
			if self.rect.collidepoint(*get_mouse_pos()):
				self.command()


class Entity:
	def __init__(self):
		self.width = self.texs[0].width
		self.height = self.texs[0].height

	def animate(self, texs, rects, freq):
		self.anim += freq
		if self.anim >= len(rects):
			self.anim = 0
		self.tex = texs[int(self.anim)]
		self.rect = rects[int(self.anim)]

	def base_update(self, win, x_pos, y_pos, anim):
		if anim:
			self.animate(self.texs, self.rects, 0.1)
		self.rect.x = x_pos
		self.rect.y = y_pos
		win.renderer.blit(self.tex, self.rect)

	def wasd(self, x_vel, y_vel):
		keys = pygame.key.get_pressed()
		if keys[pygame.K_w]:
			self.y_pos -= y_vel
		if keys[pygame.K_a]:
			self.x_pos -= x_vel
		if keys[pygame.K_s]:
			self.y_pos += y_vel
		if keys[pygame.K_d]:
			self.x_pos += x_vel


class Block(Entity):
	def __init__(self, pos, img, win):
		self.x_pos, self.y_pos = pos
		self.anim = 0
		self.tex, self.rect = load_tex(f'assets/{img}.png', win.renderer, 1)

	def update(self, win, vel):
		self.wasd(*vel)
		self.base_update(win, self.x_pos, self.y_pos, False)
