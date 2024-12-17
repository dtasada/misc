use std::{
    collections::HashMap,
    io::{Error, ErrorKind, Result},
};

use super::tokens::*;
use super::types::*;

#[derive(PartialEq, Eq, Hash)]
pub enum BindingPower {
    // Do not change order
    Default,
    Comma,
    Assignment,
    Logical,
    Relational,
    Additive,
    Multiplicative,
    Unary,
    Call,
    Member,
    Primary,
}

type LedHandler = fn(p: &Parser, left: Expr, bp: BindingPower) -> Expr;
type NudHandler = fn(p: &Parser) -> Expr;

pub struct Parser {
    tokens: Vec<Token>,
    position: usize,
    led_lookup: HashMap<Token, LedHandler>,
    nud_lookup: HashMap<Token, NudHandler>,
}

impl Parser {
    pub fn new(tokens: Vec<Token>) -> Self {
        let parser = Self {
            tokens,
            position: 0,
            led_lookup: HashMap::new(),
            nud_lookup: HashMap::new(),
        };

        parser.set_token_handlers();
        parser.set_token_type_handlers();

        parser
    }

    fn set_token_handlers(&self) {}
    fn set_token_type_handlers(&self) {}

    pub fn parse(&mut self) -> Expr {
        let mut body = Expr::Blank;

        while self.has_tokens() {
            println!("has_token: {:?}\r", self.parse_token(self.current_token()));
            self.position += 1
        }

        body
    }

    fn parse_token(&mut self, token: Token) -> Expr {
        match token {
            Token::Ident(ident) => Expr::Ident(ident),
            Token::Number(val) => Expr::Number(val),
            // Grouping
            Token::Whitespace(_) => Expr::Blank,
            Token::LeftParen => {
                let remainder = self.tokens[self.position..].to_vec();
            }
            Token::RightParen => {}
            // Binary
            Token::Plus
            | Token::Minus
            | Token::Asterisk
            | Token::Slash
            | Token::Percent
            | Token::EqualsEquals
            | Token::BangEquals
            | Token::GreaterThan
            | Token::LessThan
            | Token::GreaterEquals
            | Token::LessEquals
            | Token::Caret => {
                let bp = match token {
                    Token::Plus | Token::Minus => BindingPower::Additive,
                    Token::Asterisk | Token::Slash | Token::Percent | Token::Caret => {
                        BindingPower::Multiplicative
                    }
                    Token::EqualsEquals
                    | Token::BangEquals
                    | Token::GreaterThan
                    | Token::LessThan
                    | Token::GreaterEquals
                    | Token::LessEquals => BindingPower::Relational,
                    _ => BindingPower::Default,
                };
                let left = self.parse_token(self.previous_token().unwrap().to_owned());
                self.position += 1;
                self.parse_token(self.current_token())
            }
            // // Assignment
            // Token::Equals
            // | Token::PlusEquals
            // | Token::MinusEquals
            // | Token::TimesEquals
            // | Token::SlashEquals
            // | Token::ModEquals => {}
            // // Unary
            // Token::PlusPlus | Token::MinusMinus => {}
            // // Other
            // Token::Bang => {}
            // Token::Pipe => {}
            // Token::PipeGreater => {}
            // Token::Unknown(_) => {}
            // Token::EOL => {}
            _ => Expr::Blank,
        }
    }

    fn current_token(&self) -> Token {
        self.tokens[self.position].clone()
    }
    fn next_token(&self) -> Option<&Token> {
        self.tokens.get(self.position + 1)
    }
    fn previous_token(&self) -> Option<&Token> {
        self.tokens.get(self.position - 1)
    }
    fn has_tokens(&self) -> bool {
        self.position < self.tokens.len() && self.current_token() != Token::EOL
    }

    fn expect_or(&mut self, expected: Token, err: Result<()>) -> Result<Token> {
        let token = self.current_token();

        if token != expected {
            return match err {
                Err(e) => Err(e),
                _ => Err(Error::new(
                    ErrorKind::Other,
                    format!("Expected {:?} but received {:?} instead\n", expected, token),
                )),
            };
        }

        self.position += 1;
        Ok(self.current_token())
    }
}
