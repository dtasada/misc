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

fn print_prompt(stdout: &mut io::Stdout) -> io::Result<()> {
    print_colored(">>> ", Color::Cyan)?;
    stdout.flush()?;
    Ok(())
}

fn print_colored(text: &str, color: Color) -> io::Result<()> {
    let mut stdout = io::stdout();
    stdout.execute(crossterm::style::SetForegroundColor(color))?;
    print!("{}", text);
    stdout.execute(crossterm::style::ResetColor)?;
    Ok(())
}

fn execute_command(command: &str) -> String {
    let tokens = Lexer::new(command.to_string()).tokenize();

    let token_str: String = tokens.iter().map(|token| format!("{:?} ", token)).collect();

    format!("{}\nCommand executed", token_str)
}

fn main() -> io::Result<()> {
    // Enable raw mode
    terminal::enable_raw_mode()?;

    // Ensure terminal is restored to original state on panic or exit
    let mut stdout = io::stdout();

    println!("Math REPL");

    let mut history = Vec::<String>::new();
    let mut history_index = 0;
    let mut input = String::new();
    let mut cursor_position = 0usize;

    loop {
        stdout.execute(cursor::MoveToColumn(0))?;
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
                        println!("");
                        print_colored("Exited Math REPL", Color::Green)?;
                        break;
                    }

                    // Exit command
                    (KeyCode::Char('q'), KeyModifiers::CONTROL) if input == "exit" => {
                        print_colored("Exited Math REPL", Color::Green)?;
                        break;
                    }

                    // Enter key
                    (KeyCode::Enter, _) => {
                        println!(); // Move to next line

                        if !input.is_empty() {
                            history.push(input.clone());

                            stdout.execute(cursor::MoveToColumn(0))?;
                            let output = execute_command(&input);

                            print_colored(&output, Color::Blue)?;

                            input.clear();
                            cursor_position = 0;
                            history_index = 0;
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
                        println!("Up key pressed");
                        println!("history_index: {}", history_index);
                        if let Some(last_command) = history.last() {
                            println!("last_command: {}", last_command);
                            input = last_command.clone();
                            cursor_position = input.len();
                            history_index = (history_index + 1).max(history.len());
                        }
                    }

                    (KeyCode::Down, _) => {
                        println!("Down key pressed");
                        println!("history_index  1: {}", history_index);
                        input = history[history.len() - 1 - history_index].clone();
                        cursor_position = input.len();
                        history_index = (history_index as isize - 1).max(0) as usize;
                        println!("history_index  2: {}", history_index);
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
