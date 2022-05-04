grammar ZH;

options {
    language = Java;
}

@header {
}

@members {
    public static void main(String[] args) throws Exception {
         ZHLexer lex = new ZHLexer(new ANTLRFileStream(args[0]));
         CommonTokenStream tokens = new CommonTokenStream(lex);
         ZHParser parser = new ZHParser(tokens);
         parser.start();
    }
}

start
    :
    ;

ID       : [a-zA-Z]+ ;
NUMBER   : [0-9]+;
LF       : '\n' -> skip ;
WS       : [ \t\r]+ ->skip ;
COMMENT  : '#' (~[\n])* ->skip ;
