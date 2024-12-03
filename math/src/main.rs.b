mod lexer;
use lexer::lexer::*;

use crossterm::{
    event::{self, Event, KeyCode, KeyEventKind, KeyModifiers},
    execute,
    style::Color,
    terminal::{self, ClearType},
    ExecutableCommand,
};
use std::io::{self, Write};

fn print_prompt() -> io::Result<()> {
    let mut stdout = io::stdout();
    stdout.execute(crossterm::style::SetForegroundColor(Color::Cyan))?;
    print!(">>> ");
    io::stdout().flush()?;
    stdout.execute(crossterm::style::ResetColor)?;

    Ok(())
}

fn print_colored(text: &str, color: Color) -> io::Result<()> {
    let mut stdout = io::stdout();

    stdout.execute(crossterm::style::SetForegroundColor(color))?;
    println!("{}", text);
    stdout.execute(crossterm::style::ResetColor)?;

    Ok(())
}

fn execute_command(command: &str) -> String {
    let tokens = Lexer::new(command.to_string()).tokenize();

    for token in &tokens {
        print!("{:?} ", token);
    }

    String::from("\nCommand executed")
}

fn main() -> io::Result<()> {
    println!("Math REPL");

    terminal::enable_raw_mode()?;

    let mut stdout = io::stdout();

    let mut history = Vec::<String>::new();
    let mut history_index: Option<usize> = None;
    let mut input = String::new();

    /* loop {
        print_prompt();

        input.clear();

        if io::stdin().read_line(&mut input).is_err() {
            eprintln!("Error reading input");
            continue;
        }

        let input_command = input.trim().to_string();
        let command = if event::poll(std::time::Duration::from_millis(500)).unwrap() {
            if let Event::Key(key_event) = event::read().unwrap() {
                println!("key_event {:?}", key_event);
                match key_event.code {
                    KeyCode::Up => history.last().to_owned().unwrap().clone(),
                    _ => input_command,
                }
            } else {
                input_command
            }
        } else {
            input_command
        };

        history.push(command.to_string());
        if command == "exit" {
            print_colored("Exited Math REPL\n", Color::Green);
            break;
        }

        // Execute the command and display the output
        let output = execute_command(&command);
        print_colored(&output, Color::Blue);
    } */

    loop {
        if let Event::Key(event) = event::read()? {
            if event.kind == KeyEventKind::Press {
                match event.code {
                    KeyCode::Enter => {
                        println!();

                        if !input.is_empty() {
                            history.push(input.clone());

                            if input == "exit" {
                                print_colored("Exited Math REPL\n", Color::Green)?;
                                break;
                            }

                            let output = execute_command(&input);
                            print_colored(&output, Color::Blue)?;

                            input.clear();
                            history_index = None;
                        }

                        print_prompt()?;
                    }
                    KeyCode::Backspace => {
                        if !input.is_empty() {
                            input.pop();

                            // Clear the current line and reprint
                            execute!(stdout, terminal::Clear(ClearType::CurrentLine))?;
                            print_prompt()?;
                            print!("{}", input);
                            stdout.flush()?;
                        }
                    }
                    KeyCode::Char('d') if event.modifiers == KeyModifiers::CONTROL => {
                        print_colored("Exited Math REPL\n", Color::Green)?;
                        break;
                    }
                    KeyCode::Char(c) => {
                        input.push(c);
                    }
                    _ => {}
                }
            }
        }

        stdout.execute(terminal::Clear(ClearType::CurrentLine))?;
        stdout.flush()?;
        print!("{}", input);
        stdout.flush()?;
    }

    terminal::disable_raw_mode()?;

    Ok(())
}
