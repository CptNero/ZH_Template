grammar Car;

options {
    language = Java;
}

@header {
    import java.util.HashMap;
    import java.util.LinkedHashMap;
}

@members {
    public static void main(String[] args) throws Exception {
         CarLexer lex = new CarLexer(new ANTLRFileStream(args[0]));
         CommonTokenStream tokens = new CommonTokenStream (lex);
         CarParser parser = new CarParser(tokens);
         parser.start();
    }                                                           
}

start
    @init {
        LinkedHashMap<String, HashMap<String, Double>> garage = new LinkedHashMap<String, HashMap<String, Double>>();
    }
    @after {
        for (String key : garage.keySet()) {
            System.out.println(key + " " + (garage.get(key).toString()));
        }
    }
    : ((line[garage])* LF?)? EOF
    ;

line [ LinkedHashMap<String, HashMap<String, Double>> garage ]
    @init {
        HashMap<String, Double> carMap = new HashMap<String, Double>();
    }
    : keyword ':' property_list[carMap] ';' {
        garage.put($keyword.name, carMap);
    }
    | '[' filter_list ']'
    | '=' value_eq[garage.get("Opel Astra")] { System.out.println("Cars value: " + $value_eq.value); }
    ;

property_list [ HashMap<String, Double> carMap ]

    : metric[carMap] ((',') property_list[carMap])*
    | keyword ((',') property_list[carMap])* {
        carMap.put($keyword.name, 1.0);
    }
    ;

metric [ HashMap<String, Double> carMap ]
    : UNIT { carMap.put($UNIT.text, 1.0); }
    | number UNIT { carMap.put($UNIT.text.toLowerCase(), $number.value); }
    | year {
        carMap.put("evjarat", $year.date.year);
        carMap.put("evjarat_ho", $year.date.month);
    }
    ;

number returns [ double value ]
    : NUMBER { $value = Double.parseDouble($NUMBER.text); }
    ;

year returns [ Date date ]
    : YEAR=NUMBER '/' MONTH=NUMBER {
       double year = Integer.parseInt($YEAR.text);
       double month = Integer.parseInt($MONTH.text);
       $date = new Date(year, month);
    }
    ;

keyword returns [ String name ]
    : NAME keyword { $name = $NAME.text + " " + $keyword.name; }
    | NAME { $name = $NAME.text; }
    ;

filter_list
    : filter_rule ((',') filter_rule)*
    ;

filter_rule
    : keyword
    | condition
    ;

condition
    : operand CMP_OP operand (CMP_OP operand)?
    ;

operand
    : UNIT
    | year
    | number
    ;

value_eq [ HashMap<String, Double> car ] returns [ double value ]
    : first=add_op[car] { $value = $first.value; } (OP_ADD second=add_op[car] {
        if ($OP_ADD.equals("+")) {
            $value = $first.value + $second.value;
        } else {
            $value = $first.value - $second.value;
        }
     })*
    ;

add_op[HashMap<String, Double> car] returns [ double value ]
    : first=mul_op[car] { $value = $first.value; } ('/' second=mul_op[car] { $value = $first.value / $second.value; })*
    | first=mul_op[car] { $value = $first.value; } ('*' second=mul_op[car] { $value = $first.value * $second.value; })*
    ;

mul_op[HashMap<String, Double> car] returns [ double value ]
    : UNIT {
        Double memberValue = car.get($UNIT.text.toLowerCase());
        $value = (memberValue == null) ? 1 : memberValue;
    }
    | keyword {
        Double memberValue = car.get($keyword.name);
        $value = (memberValue == null) ? 1 : memberValue;
    }
    | NUMBER { $value = Double.parseDouble($NUMBER.text); }
    | LPAR value_eq[car] RPAR { $value = $value_eq.value; }
    ;

UNIT   : 'LE' | 'KM' | 'Ft' | 'km' | 'FT' | 'ccm' | 'CM3' | 'ft' | 'le' | 'evjarat';
OP_ADD : '+' | '-';
OP_MUL : '*' | '/';
CMP_OP : '<' | '>' | '<=' | '>=';
LPAR: '(';
RPAR: ')';
NUMBER  : [0-9]+;
NAME     : [a-zA-Z]+;
LF       : '\n' -> skip ;
WS       : [ \t\r]+ ->skip ;
COMMENT  : '#' (~[\n])* ->skip ;
