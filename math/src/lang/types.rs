use super::tokens::*;

#[derive(Debug, Clone, PartialEq)]
pub enum Expr {
    Blank,
    Number(f64),
    Ident(String),
    Unary(Box<UnaryExpr>),
    Bin(Box<BinExpr>),
    Assignment(Box<AssignmentExpr>),
    UnparsedToken(Token),
}

#[derive(Debug, Clone)]
pub struct BinExpr {
    pub left: Expr,
    pub op: Token,
    pub right: Expr,
}

#[derive(Debug, Clone)]
pub struct UnaryExpr {
    pub operator: Token,
    pub right: Expr,
}

#[derive(Debug, Clone)]
pub struct AssignmentExpr {
    pub assignee: Expr,
    pub operator: Token,
    pub right_expr: Expr,
}

#[derive(Debug, Clone)]
pub struct CallExpr {
    pub method: Expr,
    pub arguments: Vec<Expr>,
}
