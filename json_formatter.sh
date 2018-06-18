echo "Executing $1 script"
USER=root
DB=isanteplus
mysql -u $USER -p $DB < $1 | sed 's/}/},/g' | sed 1d | sed '$ s/.$//' > $1-results.json
echo "Results saved to: $1-results.json"


