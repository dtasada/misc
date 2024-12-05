use regex::Regex;

use super::tokens::*;

pub struct Lexer {
    input: String,
    position: usize,
}

impl Lexer {
    pub fn new(input: String) -> Self {
        Lexer { input, position: 0 }
    }

    pub fn tokenize(mut self) -> Vec<Token> {
        let mut tokens = Vec::<Token>::new();

        loop {
            let token = self.next_token();
            if token == Token::EOL {
                break;
            }
            tokens.push(token);
        }

        tokens
    }

    fn peek(&self, offset: usize) -> Option<char> {
        self.input.chars().nth(self.position + offset + 1)
    }

    fn get_token(&mut self, char: char, starting_offset: usize) -> (Token, usize) {
        // get token of just the single one character
        let (single_token, single_token_length) = match char {
            '+' => (Token::Plus, 1),
            '-' => (Token::Minus, 1),
            '*' => (Token::Asterisk, 1),
            '/' => (Token::Slash, 1),
            '%' => (Token::Percent, 1),
            '^' => (Token::Caret, 1),
            '(' => (Token::LeftParen, 1),
            ')' => (Token::RightParen, 1),
            '!' => (Token::Bang, 1),
            '=' => (Token::Equals, 1),
            '|' => (Token::Pipe, 1),
            '>' => (Token::GreaterThan, 1),
            '<' => (Token::LessThan, 1),
            '0'..='9' | '.' => self.read_number(),
            'a'..='z' | 'A'..='Z' => self.read_ident(),
            ' ' => self.read_whitespace(),
            _ => (Token::Unknown, 1),
        };

        if !SPECIAL_CHARS.contains(&char) {
            return (single_token, single_token_length);
        }

        let next_char_opt = self.peek(starting_offset);
        if next_char_opt.is_some() {
            let next_char = next_char_opt.unwrap();
            let (next_token, next_token_length) = self.get_token(next_char, starting_offset + 1);

            if SPECIAL_CHARS.contains(&next_char) {
                if next_token_length > 1 {
                    return (single_token, single_token_length);
                }
                match single_token {
                    Token::Plus => match next_token {
                        Token::Plus => (Token::PlusPlus, 2),
                        Token::Equals => (Token::PlusEquals, 2),
                        _ => (Token::Plus, 1),
                    },
                    Token::Minus => match next_token {
                        Token::Minus => (Token::MinusMinus, 2),
                        Token::Equals => (Token::MinusEquals, 2),
                        _ => (Token::Minus, 1),
                    },
                    Token::Asterisk => match next_token {
                        Token::Equals => (Token::TimesEquals, 2),
                        _ => (Token::Asterisk, 1),
                    },
                    Token::Slash => match next_token {
                        Token::Equals => (Token::SlashEquals, 2),
                        _ => (Token::Slash, 1),
                    },
                    Token::Percent => match next_token {
                        Token::Equals => (Token::ModEquals, 2),
                        _ => (Token::Percent, 1),
                    },
                    Token::Caret => (Token::Caret, 1),
                    Token::LeftParen => (Token::LeftParen, 1),
                    Token::RightParen => (Token::RightParen, 1),
                    Token::Bang => match next_token {
                        Token::Equals => (Token::BangEquals, 2),
                        _ => (Token::Bang, 1),
                    },
                    Token::Equals => match next_token {
                        Token::Equals => (Token::EqualsEquals, 2),
                        _ => (Token::Equals, 1),
                    },
                    Token::Pipe => match next_token {
                        Token::GreaterThan => (Token::PipeGreater, 2),
                        _ => (Token::Pipe, 1),
                    },
                    Token::GreaterThan => match next_token {
                        Token::Equals => (Token::GreaterEquals, 2),
                        _ => (Token::GreaterThan, 1),
                    },
                    Token::LessThan => match next_token {
                        Token::Equals => (Token::LessEquals, 2),
                        _ => (Token::LessThan, 1),
                    },
                    Token::Number(_) | Token::Identifier(_) | Token::Whitespace(_) => {
                        (single_token, single_token_length)
                    }
                    _ => (Token::Unknown, 1),
                }
            } else {
                match single_token {
                    Token::Plus => match next_token {
                        Token::Number(number) => (Token::Number(number), next_token_length),
                        _ => (Token::Plus, 1),
                    },
                    Token::Minus => match next_token {
                        Token::Number(number) => (Token::Number(-number), next_token_length),
                        _ => (Token::Minus, 1),
                    },
                    _ => (single_token, single_token_length),
                }
            }
        } else {
            (single_token, single_token_length)
        }
    }

    fn next_token(&mut self) -> Token {
        if self.position > self.input.len() - 1 {
            return Token::EOL;
        }

        let current_char = self.input.chars().nth(self.position).unwrap();
        let (token, len) = self.get_token(current_char, 0);

        self.position += len;

        token
    }

    fn read_number(&mut self) -> (Token, usize) {
        let word = &self.input[self.position..];
        let re = Regex::new(r"[-+]?\d*\.?\d+([eE][-+]?\d+)?").unwrap();

        if let Some(mat) = re.find(word) {
            let num_str = mat.as_str();
            (
                Token::Number(num_str.parse::<f64>().unwrap()),
                num_str.len(),
            )
        } else {
            (Token::InvalidNumber, 0)
        }
    }

    fn read_ident(&mut self) -> (Token, usize) {
        let not_ident = Regex::new(r"[^a-zA-Z_]").unwrap();
        let word = self
            .input
            .split_at(self.position)
            .1
            .split_whitespace()
            .collect::<Vec<&str>>()[0];
        let ident = not_ident.split(word).collect::<Vec<&str>>()[0];
        (Token::Identifier(ident.to_string()), ident.len())
    }

    fn read_whitespace(&mut self) -> (Token, usize) {
        let len = self
            .input
            .split_at(self.position)
            .1
            .chars()
            .take_while(|c| c.is_whitespace())
            .count();
        (Token::Whitespace(len), len)
    }
}
