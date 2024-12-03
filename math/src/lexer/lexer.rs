use super::tokens::*;

pub struct Lexer {
    input: String,
    position: usize,
}

impl Lexer {
    pub fn new(input: String) -> Self {
        Lexer { input, position: 0 }
    }

    pub fn tokenize(&mut self) -> Vec<Token> {
        let mut tokens = vec![];

        loop {
            let token = self.next_token(false);
            if token == Token::EOL {
                break;
            }
            tokens.push(token);
        }

        tokens
    }

    fn next_token(&mut self, recursive: bool) -> Token {
        if self.position > self.input.len() - 1 {
            return Token::EOL;
        }

        let current_char = self.input.chars().nth(self.position).unwrap();

        let (token, len) = match current_char {
            '+' => (Token::Plus, 1),
            '-' => (Token::Minus, 1),
            '*' => (Token::Asterisk, 1),
            '/' => (Token::Slash, 1),
            '^' => (Token::Caret, 1),
            '(' => (Token::LeftParen, 1),
            ')' => (Token::RightParen, 1),
            '!' => (Token::Bang, 1),
            '=' => (Token::Equals, 1),
            '|' => (Token::Pipe, 1),
            '>' => (Token::Greater, 1),
            '<' => (Token::Less, 1),
            '0'..='9' => self.read_number(),
            'a'..='z' | 'A'..='Z' => self.read_ident(),
            ' ' => (Token::Whitespace, 1),
            _ => (Token::Unkown, 1),
        };

        self.position += len;

        token
    }

    fn read_number(&mut self) -> (Token, usize) {
        let num_string = self
            .input
            .split_at(self.position)
            .1
            .split_whitespace()
            .collect::<Vec<&str>>()[0];
        (Token::Number(num_string.parse().unwrap()), num_string.len())
    }

    fn read_ident(&mut self) -> (Token, usize) {
        let ident = self
            .input
            .split_at(self.position)
            .1
            .split_whitespace()
            .collect::<Vec<&str>>()[0];
        (Token::Identifier(ident.to_string()), ident.len())
    }
}
