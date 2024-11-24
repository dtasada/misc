use std::fs::OpenOptions;

use tempfile::tempfile;

use clap::Parser;
use crossterm::{
    terminal::{self, Clear, ClearType, EnterAlternateScreen, LeaveAlternateScreen},
    ExecutableCommand,
};

mod lib;
use lib::cli::*;
use lib::thread::*;

fn main() {
    let args = Cli::parse();
    let file = if let Some(name) = args.name {
        // Create file
        OpenOptions::new()
            .read(true)
            .write(true)
            .create(true)
            .open(name)
            .unwrap()
    } else {
        // Or create tempfile
        tempfile().unwrap()
    };

    let mut t = Thread::new(file);

    terminal::enable_raw_mode().unwrap();
    t.out.execute(EnterAlternateScreen).unwrap();

    t.out.execute(Clear(ClearType::All)).unwrap();

    loop {
        t.update();
        t.draw();

        if t.quit {
            break;
        }
    }

    t.out.execute(LeaveAlternateScreen).unwrap();
    terminal::disable_raw_mode().unwrap();

    println!("lines: {:?}", t.buf.lines);
    println!("buffer: {:?}", t.buf);
}
