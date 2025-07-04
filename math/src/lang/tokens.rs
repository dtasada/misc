#[derive(Debug, PartialEq, Clone)]
pub enum Token {
    Ident(String),     // contains the name of the identifier
    Number(f64),       // contains value of the number
    Whitespace(usize), // contains length of contiguous whitespace
    Unknown(String),   // contains the unknown token
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
    GreaterThan,
    LessThan,
    GreaterEquals,
    LessEquals,
    LeftParen,
    RightParen,
    EOL,
}
