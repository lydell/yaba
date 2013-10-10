rm -f lib/*
coffee -cbo lib/ src/

component build -s yaba -o . -n yaba

coffee -cb src/ test/
browserify test/*.js > test/browser/tests.js
rm src/*.js test/*.js
