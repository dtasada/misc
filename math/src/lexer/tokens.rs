#[derive(Debug, PartialEq)]
pub enum Token {
    Identifier(String), // contains the name of the identifier
    Number(f64),        // contains value of the number
    Whitespace(usize),  // contains length of contiguous whitespace
    InvalidNumber,
    Plus,
    Minus,
    Asterisk,
    Slash,
    Percent,
    Bang,
    Equals,
    Pipe,
    PipeGreater,
    PlusEquals,
    MinusEquals,
    TimesEquals,
    SlashEquals,
    ModEquals,
    Caret,
    EqualsEquals,
    BangEquals,
    PlusPlus,
    MinusMinus,
    PlusMinus,
    GreaterThan,
    LessThan,
    GreaterEquals,
    LessEquals,
    LeftParen,
    RightParen,
    Unknown,
    EOL,
}

pub const SPECIAL_CHARS: [char; 13] = [
    '+', '-', '*', '/', '%', '^', '(', ')', '!', '=', '|', '>', '<',
];
