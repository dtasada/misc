in = ./src/*.cpp
out = ./cucumber
link = -lSDL2 -lSDL2_image -lSDL2_ttf -lSDL2_mixer
args = -std=c++23 -Wall -O3

build:
	g++ $(args) $(in) $(link) -o $(out)

run: build
	$(out)

clean:
	rm -r ./target
