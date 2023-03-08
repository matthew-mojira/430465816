data Op
  = Add1
  | Sub1

data Expr
  = Int16 Int
  | Prim1 Op Expr

compile :: Expr -> String
compile e = concat (concat [["entry:\n"], compileE e, ["RTL"]])

compileE :: Expr -> [String]
compileE (Int16 i) = compileInt i
compileE (Prim1 op e) = compilePrim1 op e

compileInt :: Int -> [String]
compileInt i = ["LDA #" ++ show i ++ "\n"]

compilePrim1 :: Op -> Expr -> [String]
compilePrim1 Add1 e = concat [compileE e, ["INC\n"]]
compilePrim1 Sub1 e = concat [compileE e, ["DEC\n"]]
