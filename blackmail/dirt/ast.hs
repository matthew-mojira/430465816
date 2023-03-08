data Op
  = Add1
  | Sub1

data Expr
  = Int16 Int
  | Prim1 Op Expr
