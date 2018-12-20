package saturn.db.query_lang;
class Cast extends Function{
    public function new(expression : Token, type: Token) {
        super([expression, type]);
    }
}
