use sdl2::{event::Event, keyboard::Keycode, rect::Rect};

mod engine;
use engine::*;

fn main() -> Result<(), String> {
    // Base SDL requirements
    let context: sdl2::Sdl = sdl2::init().unwrap();
    let subsystem = context.video().unwrap();
    let mut events = context.event_pump()?;

    let window = subsystem
        .window("cool war game", 1280, 720)
        .opengl()
        .build()
        .map_err(|e| e.to_string())
        .unwrap();

    let mut canvas = window
        .into_canvas()
        .accelerated()
        .target_texture()
        .build()
        .unwrap();

    let texture_creator = canvas.texture_creator();

    // My engine init
    let mut game = Game::new();

    let mut map = Sprite::new(
        &texture_creator,
        0,
        0,
        canvas.output_size().unwrap().0,
        canvas.output_size().unwrap().1,
        "assets/map.jpg",
        None,
    );

    /* let mut title = Sprite::new(
        &texture_creator,
        0,
        0,
        canvas.output_size().unwrap().0,
        canvas.output_size().unwrap().1,
        "assets/title.png",
        Some(110),
    ); */

    while game.running {
        for key in events.keyboard_state().pressed_scancodes() {
            match Keycode::from_scancode(key).unwrap() {
                Keycode::W => map.rect.y -= 1,
                Keycode::A => map.rect.x -= 1,
                Keycode::S => map.rect.y += 1,
                Keycode::D => map.rect.x += 1,
                _ => {}
            }
        }

        let mouse = events.mouse_state();
        for event in events.poll_iter() {
            match event {
                Event::Quit { .. } => game.running = false,
                Event::KeyDown {
                    keycode: Some(keycode),
                    timestamp,
                    ..
                } => match keycode {
                    Keycode::Space => {}
                    Keycode::T => println!("timestamp: {}", timestamp),
                    Keycode::Escape => game.running = false,
                    _ => {}
                },
                Event::MouseWheel { y, .. } => {
                    let multiplier = if y > 0 { 2.0 } else { 1.0 / 2.0 };

                    let og_width = map.rect.width() as f32;
                    let og_height = map.rect.height() as f32;

                    let ratio_x = mouse.x() as f32 / og_width;
                    let ratio_y = mouse.y() as f32 / og_height;

                    map.rect.set_width((og_width * multiplier) as u32);
                    map.rect.set_height((og_height * multiplier) as u32);

                    map.rect
                        .set_x((mouse.x() as f32 - map.rect.width() as f32 * ratio_x) as i32);
                    map.rect
                        .set_y((mouse.y() as f32 - map.rect.height() as f32 * ratio_y) as i32);
                }
                _ => {}
            }
        }

        canvas.clear();

        canvas.set_draw_color((255, 255, 255, 255));
        canvas.fill_rect(Rect::new(0, 0, 1280, 720)).unwrap();

        match game.state {
            State::Menu => {
                // title.render(&mut canvas);
            }
            State::Play => {
                map.render(&mut canvas);
            }
            _ => {}
        }

        canvas.present();

        game.framerate.delay();
    }

    Ok(())
}
