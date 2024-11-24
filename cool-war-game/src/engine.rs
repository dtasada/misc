use sdl2::{
    gfx::{framerate::FPSManager, primitives::DrawRenderer},
    image::{InitFlag, LoadSurface, LoadTexture, Sdl2ImageContext},
    rect::Rect,
    render::{SurfaceCanvas, Texture, TextureCreator, WindowCanvas},
    surface::Surface,
    video::WindowContext,
};

pub enum State {
    Menu,
    Play,
    SettingsMenu,
    SettingsPlay,
}

pub struct Game {
    pub running: bool,
    pub framerate: FPSManager,
    pub image_context: Sdl2ImageContext,
    pub state: State,
}

impl Game {
    pub fn new() -> Self {
        let mut framerate = FPSManager::new();
        framerate.set_framerate(60).unwrap();

        Self {
            running: true,
            framerate,
            image_context: sdl2::image::init(InitFlag::PNG | InitFlag::JPG).unwrap(),
            state: State::Play,
        }
    }
}

pub struct Sprite<'a> {
    pub texture: Texture<'a>,
    pub rect: Rect,
    textures: Option<Vec<Texture<'a>>>,
}

impl<'a> Sprite<'a> {
    pub fn new(
        texture_creator: &'a TextureCreator<WindowContext>,
        x: i32,
        y: i32,
        w: u32,
        h: u32,
        img_path: &str,
        frames: Option<u8>,
    ) -> Self {
        Self {
            texture: texture_creator.load_texture(img_path).unwrap(),
            rect: Rect::new(x, y, w, h),
            textures: if frames == None {
                None
            } else {
                let monolith = texture_creator.load_texture(img_path).unwrap();
                let monolith_s = Surface::from_file("assets/title.png")
                    .unwrap()
                    .into_canvas()
                    .unwrap();
                None //placeholder
            },
        }
    }

    pub fn render(&self, canvas: &mut WindowCanvas) {
        canvas.copy(&self.texture, None, self.rect).unwrap();
    }
}

pub struct Text {
    pub content: String,
}
