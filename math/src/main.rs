use crossterm::{
    cursor,
    event::{self, Event, KeyCode, KeyModifiers},
    style::Color,
    terminal::{self, ClearType},
    ExecutableCommand,
};
use std::{
    io::{self, Error, ErrorKind, Result, Write},
    time::Duration,
    usize,
};

mod lang;
use lang::{lexer::*, parser::*, tokens::*};

macro_rules! col0 {
    () => {
        io::stdout().execute(cursor::MoveToColumn(0)).unwrap();
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

fn print_prompt() -> Result<()> {
    print_colored(">>> ", Color::Cyan)?;
    io::stdout().flush()?;
    Ok(())
}

fn print_colored(text: &str, color: Color) -> Result<()> {
    let mut stdout = io::stdout();
    stdout.execute(crossterm::style::SetForegroundColor(color))?;
    print0!("{}", text);
    stdout.execute(crossterm::style::ResetColor)?;
    stdout.flush()?;
    Ok(())
}

fn execute_command(command: &str) -> Result<String> {
    let tokens = Lexer::new(command.to_string()).tokenize();
    for t in &tokens {
        if let Token::Unknown(token) = t {
            return Err(Error::new(
                ErrorKind::NotFound,
                format!("Error: unkown token {:?}\n", token),
            ));
        }
    }

    let tree = Parser::new(tokens.clone()).parse();

    Ok(format!("tokens: {:?}\r\ntree: {:?}\n", tokens, tree))
}

fn main() -> Result<()> {
    terminal::enable_raw_mode()?;
    std::panic::set_hook(Box::new(|_| terminal::disable_raw_mode().unwrap()));

    let mut stdout = io::stdout();

    println0!("Math REPL");

    let mut input = String::new();
    let mut history = Vec::<String>::new();
    let mut history_index: usize = 0;
    let mut cursor_col: usize = 0;
    let mut cursor_row: usize = 0;

    loop {
        stdout.execute(terminal::Clear(ClearType::CurrentLine))?;
        print_prompt()?;

        print!("{}", input);
        stdout.flush()?;

        if event::poll(Duration::from_millis(100))? {
            if let Event::Key(key_event) = event::read()? {
                match (key_event.code, key_event.modifiers) {
                    (KeyCode::Char('d'), KeyModifiers::CONTROL) => {
                        println0!();
                        print_colored("Exited Math REPL\r\n", Color::Green)?;
                        break;
                    }

                    (KeyCode::Char('c'), KeyModifiers::CONTROL) => {
                        println0!(); // Move to next line
                        input.clear();
                    }
                    (KeyCode::Char('a'), KeyModifiers::CONTROL) => cursor_col = 0,
                    (KeyCode::Char('e'), KeyModifiers::CONTROL) => cursor_col = input.len(),
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

                        cursor_col = input.len();
                    }

                    (KeyCode::Enter, _) => {
                        if input == "exit" {
                            println0!();
                            print_colored("Exited Math REPL\r\n", Color::Green)?;
                            break;
                        }

                        println0!(); // Move to next line

                        if !input.is_empty() {
                            history.push(input.clone());

                            let output = execute_command(&input);

                            match output {
                                Ok(output) => print_colored(&output, Color::Blue)?,
                                Err(e) => print_colored(&e.to_string(), Color::Red)?,
                            }

                            input.clear();
                            cursor_col = 0;
                            history_index = 0;

                            col0!();
                        }
                    }

                    // Backspace
                    (KeyCode::Backspace, _) => {
                        if !input.is_empty() && cursor_col > 0 {
                            input.remove(cursor_col - 1);
                            cursor_col -= 1;
                        }
                    }

                    (KeyCode::Up, _) => {
                        if let Some(last_command) = history.last() {
                            input = last_command.clone();
                            cursor_col = input.len();
                            history_index = (history_index + 1).min(history.len());
                        }
                    }

                    (KeyCode::Down, _) => {
                        input = history[history
                            .len()
                            .saturating_sub(1)
                            .saturating_sub(history_index)]
                        .clone();
                        cursor_col = input.len();
                        history_index = history_index.saturating_sub(1);
                    }

                    (KeyCode::Left, _) => {
                        if cursor_col > 0 {
                            cursor_col -= 1;
                        }
                        io::stdout().execute(cursor::MoveToColumn(0))?;
                        print!("{}\r", input);
                        io::stdout().execute(cursor::MoveToColumn(cursor_col as u16))?;
                        io::stdout().flush()?;
                    }

                    (KeyCode::Right, _) => {
                        if cursor_col < input.len() {
                            cursor_col += 1;
                        }
                        io::stdout().execute(cursor::MoveToColumn(0))?;
                        print!("{}\r", input);
                        io::stdout().execute(cursor::MoveToColumn(cursor_col as u16))?;
                        io::stdout().flush()?;
                    }
                    // Character input
                    (KeyCode::Char(c), _) => {
                        input.insert(cursor_col, c);
                        cursor_col += 1;
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
