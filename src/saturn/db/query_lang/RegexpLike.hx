package saturn.db.query_lang;
class RegexpLike extends Function{
    public function new(field, expression) {
        super([field, expression]);
    }
}
