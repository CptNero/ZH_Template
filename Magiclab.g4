grammar Magiclab;

options {
    language = Java;
}

@header {
    import java.util.HashMap;
}

@members {
    public static void main(String[] args) throws Exception {
         MagiclabLexer lex = new MagiclabLexer(new ANTLRFileStream(args[0]));
         CommonTokenStream tokens = new CommonTokenStream(lex);
         MagiclabParser parser = new MagiclabParser(tokens);
         parser.start();
    }
}

start
    @init {
        HashMap<String, Double> inv = new HashMap<String, Double>();
        HashMap<String, Recipe> recipeBook = new HashMap<String, Recipe>();
    }
    @after {
        for (String key : inv.keySet()) {
            System.out.println(key + " " + (inv.get(key).toString()));
        }
    }
    : ((line[inv, recipeBook])* LF?)? EOF
    ;

line[ HashMap<String, Double> inv, HashMap<String, Recipe> recipeBook ]
    : COMMENT
    | ITEM quantity {
        if (inv.containsKey($ITEM.text)) {
            inv.put($ITEM.text, inv.get($ITEM.text) + $quantity.value);
        } else {
            inv.put($ITEM.text, $quantity.value);
        }
    }
    | ITEM '{' recipe '}' quantity? {
        $recipe.recipeObj.makes = $quantity.value;
        $recipeBook.put($ITEM.text, $recipe.recipeObj);
    }
    | ITEM '=>' quantity {
        Recipe recipeObj = recipeBook.get($ITEM.text);

        for (String key : recipeObj.recipeMap.keySet()) {
            inv.put(key, inv.get(key) - recipeObj.recipeMap.get(key));
        }

        if (inv.containsKey($ITEM.text)) {
            inv.put($ITEM.text, inv.get($ITEM.text) + $quantity.value * recipeObj.makes);
        } else {
            inv.put($ITEM.text, $quantity.value * recipeObj.makes);
        }
    }
    ;

quantity returns [ double value ]
        :
        | SIGN NUMBER frac {
            double number = Double.parseDouble($NUMBER.text);
            number += $frac.value;
            $value = ($SIGN.text.equals("+")) ? number : -number;
        }
        | SIGN NUMBER {
            double number = Double.parseDouble($NUMBER.text);
            $value = ($SIGN.text.equals("+")) ? number : -number;
        }
        | frac { $value = $frac.value; }
        | NUMBER { $value = Double.parseDouble($NUMBER.text); }
        ;

frac returns [double value]
    : NUMERATOR=NUMBER '/' DENOMINATOR=NUMBER {
        double numerator = Double.parseDouble($NUMERATOR.text);
        double denominator = Double.parseDouble($DENOMINATOR.text);
        $value = numerator / denominator;
    }
    ;


recipe returns [ Recipe recipeObj ]
    @init {
        Recipe recipeObj = new Recipe();
    }
    :quantity ITEM (',' recipe)* {
        recipeObj.recipeMap.put($ITEM.text, $quantity.value);
        $recipeObj = recipeObj;
    }
    ;

ITEM     : [a-zA-Z]+ | '"' [a-zA-Z- ]+ '"';
SIGN     : '+' | '-';
NUMBER   : [0-9]+;
LF       : '\n' -> skip ;
WS       : [ \t\r]+ ->skip ;
COMMENT  : '#' (~[\n])* ->skip ;
