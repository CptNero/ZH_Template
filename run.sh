java -jar antlr-4.10.1-complete.jar ZH.g4
javac -cp .:antlr-4.10.1-complete.jar *.java
java -cp .:antlr-4.10.1-complete.jar org.antlr.v4.gui.TestRig ZH start input.txt -gui
#java -cp .:antlr-4.10.1-complete.jar MagiclabParser input.txt

