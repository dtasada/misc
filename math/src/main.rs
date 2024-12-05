use crossterm::{
    cursor,
    event::{self, Event, KeyCode, KeyEvent, KeyModifiers},
    execute,
    style::{Color, PrintStyledContent, StyledContent},
    terminal::{self, ClearType},
    ExecutableCommand,
};
use std::{
    io::{self, Write},
    time::Duration,
};

mod lexer;
use lexer::{lexer::*, tokens::*};

macro_rules! col0 {
    () => {
        io::stdout().execute(cursor::MoveToColumn(0))?;
    };
}

macro_rules! print0 {
    ($($arg:tt)*) => {{
        col0!();
        print!("{}", format!($($arg)*))
    }};
}
macro_rules! println0 {
    () => {
        col0!();
        print!("\n")
    };
    ($($arg:tt)*) => {{
        col0!();
        println!("{}", format!($($arg)*))
    }};
}

fn print_prompt(stdout: &mut io::Stdout) -> io::Result<()> {
    print_colored(">>> ", Color::Cyan)?;
    stdout.flush()?;
    Ok(())
}

fn print_colored(text: &str, color: Color) -> io::Result<()> {
    let mut stdout = io::stdout();
    stdout.execute(crossterm::style::SetForegroundColor(color))?;
    print0!("{}", text);
    stdout.execute(crossterm::style::ResetColor)?;
    stdout.flush()?;
    Ok(())
}

fn execute_command(command: &str) -> String {
    let tokens = Lexer::new(command.to_string()).tokenize();

    let token_str = tokens
        .iter()
        .map(|token| format!("{:?} ", token))
        .collect::<String>();

    format!("{}\nCommand executed", token_str)
}

fn main() -> io::Result<()> {
    terminal::enable_raw_mode()?;

    let mut stdout = io::stdout();

    println0!("Math REPL");

    let mut history = Vec::<String>::new();
    let mut history_index = 0;
    let mut input = String::new();
    let mut cursor_position = 0usize;

    loop {
        stdout.execute(terminal::Clear(ClearType::CurrentLine))?;
        print_prompt(&mut stdout)?;

        // Print current input
        print!("{}", input);
        stdout.flush()?;

        // Wait for key event
        if event::poll(Duration::from_millis(100))? {
            if let Event::Key(key_event) = event::read()? {
                match (key_event.code, key_event.modifiers) {
                    (KeyCode::Char('d'), KeyModifiers::CONTROL) => {
                        println0!("");
                        print_colored("Exited Math REPL\r\n", Color::Green)?;
                        break;
                    }

                    (KeyCode::Char('c'), KeyModifiers::CONTROL) => {
                        println0!(); // Move to next line
                        input.clear();
                    }

                    (KeyCode::Char('a'), KeyModifiers::CONTROL) => cursor_position = 0,

                    (KeyCode::Char('e'), KeyModifiers::CONTROL) => cursor_position = input.len(),

                    (KeyCode::Char('w'), KeyModifiers::CONTROL) => {
                        input = {
                            let mut ret = String::new();

                            if let Some(pos) = input.rfind(|c: char| !c.is_whitespace()) {
                                let trimmed = &input[..=pos];
                                if let Some(last_space) = trimmed.rfind(char::is_whitespace) {
                                    ret = input[..=last_space].to_string();
                                }
                            }

                            ret
                        };

                        cursor_position = input.len();
                    }

                    // Enter key
                    (KeyCode::Enter, _) => {
                        println!(); // Move to next line

                        if !input.is_empty() {
                            history.push(input.clone());

                            if input == "exit" {
                                print_colored("Exited Math REPL", Color::Green)?;
                                break;
                            }

                            let output = execute_command(&input);

                            print_colored(&output, Color::Blue)?;

                            input.clear();
                            cursor_position = 0;
                            history_index = 0;

                            col0!();
                        }
                    }

                    // Backspace
                    (KeyCode::Backspace, _) => {
                        if !input.is_empty() && cursor_position > 0 {
                            input.remove(cursor_position - 1);
                            cursor_position -= 1;
                        }
                    }

                    // Up arrow (history navigation)
                    (KeyCode::Up, _) => {
                        if let Some(last_command) = history.last() {
                            input = last_command.clone();
                            cursor_position = input.len();
                            history_index = (history_index + 1).min(history.len());
                        }
                    }

                    (KeyCode::Down, _) => {
                        input = history
                            [(history.len() as isize - 1 - history_index as isize).max(0) as usize]
                            .clone();
                        cursor_position = input.len();
                        history_index = (history_index as isize - 1).max(0) as usize;
                    }

                    // Character input
                    (KeyCode::Char(c), _) => {
                        input.insert(cursor_position, c);
                        cursor_position += 1;
                    }

                    _ => {} // Ignore other keys
                }
            }
        }
    }

    // Disable raw mode before exiting
    terminal::disable_raw_mode()?;

    Ok(())
}
