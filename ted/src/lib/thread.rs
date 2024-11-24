use super::buffer::*;
use super::ui::*;
use super::utils::*;

use core::panic;
use crossterm::{
    cursor::{MoveTo, MoveToColumn},
    event::{read, Event, KeyCode},
    style::{self, Print},
    terminal::{self, Clear, ClearType},
    ExecutableCommand, QueueableCommand,
};
use std::cmp::{max, min};
use std::fs::File;
use std::io::{Seek, Write};

pub struct Thread {
    pub out: std::io::Stdout,
    pub buf: Buffer,
    pub ui: Ui,
    pub size: (u16, u16),
    pub mode: Mode,
    pub quit: bool,
}

impl Thread {
    pub fn new(file: File) -> Self {
        Self {
            out: std::io::stdout(),
            buf: Buffer::new(file),
            ui: Ui::new(),
            size: terminal::size().unwrap(),
            mode: Mode::Normal,
            quit: false,
        }
    }

    fn handle_input(&mut self) {
        if let Some(action) = self.handle_event(read().unwrap()) {
            match action {
                Action::Quit => {
                    self.quit = true;
                }
                Action::Save => {
                    let output = self
                        .buf
                        .lines
                        .iter()
                        .map(|line| line.iter().collect::<String>()) // Convert Vec<char> to String
                        .collect::<Vec<String>>()
                        .join("\n");

                    self.buf.file.seek(std::io::SeekFrom::Start(0)).unwrap();
                    self.buf.file.write_all(output.as_bytes()).unwrap();
                }
                Action::MoveUp => {
                    self.buf.y = max(self.buf.y - 1, 1);
                    self.buf.x = min(self.buf.x, max(self.buf.get_line().len() as u16, 1));
                }
                Action::MoveDown => {
                    self.buf.y = min(self.buf.y + 1, self.buf.lines.len() as u16);
                    self.buf.x = min(self.buf.x, max(self.buf.get_line().len() as u16, 1));
                }
                Action::MoveLeft => {
                    self.buf.x = max(self.buf.x - 1, 1);
                }
                Action::MoveRight => {
                    self.buf.x = min(self.buf.x + 1, self.buf.get_line().len() as u16);
                }
                Action::EnterMode(new_mode) => {
                    self.mode = new_mode;
                }
            }
        }
    }

    pub fn handle_event(&mut self, ev: Event) -> Option<Action> {
        match self.mode {
            Mode::Normal => self.handle_normal_event(ev),
            Mode::Insert => self.handle_insert_event(ev),
        }
    }

    pub fn handle_normal_event(&mut self, ev: Event) -> Option<Action> {
        match ev {
            Event::Key(event) => match event.code {
                KeyCode::Char('q') => Some(Action::Quit),
                KeyCode::Char('e') => Some(Action::Save),
                KeyCode::Char('k') => Some(Action::MoveUp),
                KeyCode::Char('j') => Some(Action::MoveDown),
                KeyCode::Char('h') => Some(Action::MoveLeft),
                KeyCode::Char('l') => Some(Action::MoveRight),
                KeyCode::Char('i') => Some(Action::EnterMode(Mode::Insert)),
                _ => None,
            },
            _ => None,
        }
    }

    pub fn handle_insert_event(&mut self, ev: Event) -> Option<Action> {
        match ev {
            Event::Key(event) => match event.code {
                KeyCode::Esc => Some(Action::EnterMode(Mode::Normal)),
                KeyCode::Char(ch) => {
                    self.buf.x += 1;
                    self.buf.push_char(ch);
                    None
                }
                KeyCode::Enter => {
                    self.buf.push_empty_line();
                    self.buf.y += 1;
                    self.buf.x = min(self.buf.x, self.buf.get_line().len() as u16);
                    None
                }
                _ => None,
            },
            _ => None,
        }
    }

    fn draw_status_line(&mut self) {
        self.out
            .queue(MoveTo(self.ui.x_offset as u16, (self.size.1 - 2) as u16))
            .unwrap();
        self.out
            .queue(style::Print(format!(
                "{}:{} mode {}",
                self.buf.x,
                self.buf.y,
                self.mode.to_string(),
            )))
            .unwrap();
    }

    pub fn draw(&mut self) {
        self.draw_status_line();

        for (i, line) in self.buf.lines.iter().enumerate() {
            self.out.queue(MoveTo(0, i as u16)).unwrap();
            self.out.queue(Print(i + 1)).unwrap();

            for (j, ch) in line.iter().enumerate() {
                self.out
                    .queue(MoveToColumn((j + self.ui.x_offset as usize) as u16))
                    .unwrap();
                self.out.queue(Print(ch)).unwrap();
            }
        }

        self.out.queue(MoveTo(self.ui.x, self.ui.y)).unwrap();
        self.out.flush().unwrap();
    }

    pub fn update(&mut self) {
        if self.buf.x == 0 || self.buf.y == 0 {
            panic!("bufx: {} bufy {}", self.buf.x, self.buf.y);
        }
        self.ui.x = self.buf.x - 1 + self.ui.x_offset as u16;
        self.ui.y = self.buf.y - 1 + self.ui.y_offset as u16;

        self.draw();
        self.handle_input();
    }
}
