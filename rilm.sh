#rilm.sh
#!/bin/bash -e


green="`tput setaf 2`"
red="`tput setaf 1`"
sgr0="`tput sgr0`"
cyan="`tput setaf 6`"

# Git-Synchronisation (https://github.com/musikforschung)
REPOS=(
"$HOME/rilm/marc2bibtex/"
"$HOME/rilm/pica2bibtex/"
"$HOME/rilm/rilm_shell/"
"$HOME/lib/Catmandu/Exporter/"
)

echo "Prüfe auf Aktualisierungen..."

for repo_path in "${REPOS[@]}"; do
   if [ ! -d "$repo_path" ]; then
      echo "Fehler: Verzeichnis nicht gefunden: $repo_path!" 
	     continue
   fi

   cd "$repo_path" || { echo  "Fehler: Konnte nicht in $repo_path wechseln!"; continue; }
   git fetch &> /dev/null
   if [ $? -ne 0 ]; then
      echo "Fehler beim Abrufen der Remote_Daten."
      continue
   fi
   STATUS=$(git status)
   if [[ $STATUS =~ "Ihr Branch ist auf demselben Stand wie" ]]; then
      echo "$repo_path ist aktuell"
   elif [[ $STATUS =~ "git pull" ]]; then
      echo "Aktualisierungen für $repo_path gefunden"
      git config pull.rebase false && git pull &> /dev/null
      echo "$repo_path wurde aktualisiert"
   else
      echo "Bitte Aktualisierungen prüfen."
      echo "$STATUS"
   fi
done
echo "------------------------------------------------------"
echo "Synchronisierung abgeschlossen.
"
#cd $HOME/rilm

##Abruf und Transformation der RILM-Daten
## Abfrage des aktuellen RILM-Stempels "JJJJ-MM-TT"
read -p "${cyan}			Bitte den aktuellen RILM-Stempel in der Form JJJJ-MM-TT eingeben: ${sgr0}" Date
while [[ ! "$Date" =~ ^20[23][0-9]-(0[369]|12)-(0?[1-9]|[12][0-9]|3[01])$ ]] ; do
  echo "${red}Ungültige Eingabe. Der Stempel besteht aus einer Datumsangabe in der Form JJJJ-MM-TT. Erlaubte Werte für MM = 03,06,09,12.${sgr0}"
  read -p "${cyan}			Bitte den aktuellen RILM-Stempel eingeben: ${sgr0}" Date
done
echo "
Transformation der BMS-Daten nach BibTeX gestartet."

# Löscht überflüssige Einträge im PICA-Abzug. 
sed -i '/^nohup:/d' $HOME/rilm/dmpbms_${Date}.pp &&

# Alte Dateien Löschen oder Verschieben.
if [ -f $HOME/rilm/dmpbms*.btx ]; then
   mv dmpbms*.btx $HOME/rilm/ablage/
fi &&

if [ -f $HOME/rilm/oenb*.mrk ]; then
   rm $HOME/rilm/oenb*.mrk
fi &&

if [ -f $HOME/rilm/marc2bibtex/data/oenb_[0-9]*.mrk ]; then
   mv $HOME/rilm/marc2bibtex/data/oenb_[0-9]*.mrk $HOME/rilm/marc2bibtex/ablage/
fi &&

if [ -f $HOME/rilm/pica2bibtex/dmpbms*.pp ]; then
   rm $HOME/rilm/pica2bibtex/dmpbms*.pp
fi &&


# Kopiere PICA_Datei in Arbeitsverzeichnis
cp -f $HOME/rilm/dmpbms_${Date}.pp $HOME/rilm/pica2bibtex/ &&

# Wechsel in Arbeitsverzeichnis
#cd $HOME/rilm/pica2bibtex &&

# PICA-Datei auf eventuell fehlende Formschlagwörter (Festschrift/Konferenzschrift) prüfen
catmandu convert PICA --type plain to CSV --fields Festschrift,Konferenzschrift,PPN --fix $HOME/rilm/pica2bibtex/fix/formschlagwort_bms.fix < $HOME/rilm/pica2bibtex/dmpbms_${Date}.pp > $HOME/rilm/pica2bibtex/formschlagwort_bms.csv &&

if [ -f ../formschlagwort_bms.csv ]; then
   echo "${cyan}			Bitte die Datei ${green}formschlagwort_bms.csv${cyan} prüfen und bei Bedarf in der Datei ${green}dmpbms_${Date}.pp${cyan} Formschlagwörter ergänzen!!!${sgr0}"
fi

read -p "${cyan}			Mit \"${green}y${cyan}\" bestätigen, wenn die Prüfung beendet und alle Änderungen abgespeichert sind: ${sgr0}" Bestaetigung
while [[ ! "$Bestaetigung" == y ]]; do
  echo "${red}			Warte auf Bestätigung${sgr0}"
  read -p "			Mit \"${green}y${cyan}\" bestätigen, wenn die Prüfung beendet und alle Änderungen abgespeichert sind: " Bestaetigung
done  

echo "Transformation der BMS-Daten wird fortgesetzt."

# Kopiere aktualisierte PICA_Datei in Arbeitsverzeichnis
cp -f $HOME/rilm/pica2bibtex/dmpbms_${Date}.pp . &&

# Lösche formschalgwort_bms.csv
if [ -f $HOME/rilm/formschlagwort_bms.csv ]; then
   rm $HOME/rilm/formschlagwort_bms.csv
fi &&

# CSV von allen HAs ihrer Materialart und ihren PPNs erstellen.
catmandu convert PICA --type plain to CSV --fix $HOME/rilm/pica2bibtex/fix/type_ha.fix --fields ppn,type < $HOME/rilm/pica2bibtex/dmpbms_${Date}.pp > $HOME/rilm/pica2bibtex/data/type_ha.csv &&
# CSV_Datei der HAs ihrer PPN und ihrer zugehörigen Materialart erstellen. Wird für die Bestimmung des types der Aufsätze benötigt.
catmandu convert PICA --type plain to CSV --fix $HOME/rilm/pica2bibtex/fix/type_as.fix --fields ppn,type < $HOME/rilm/pica2bibtex/dmpbms_${Date}.pp > $HOME/rilm/pica2bibtex/data/type_as.csv &&
# CSV_Datei der HAs ihrer PPN und ihrer zugehörigen Materialart erstellen. Wird für die Bestimmung des types der Rezensionen benötigt.
catmandu convert PICA --type plain to CSV --fix $HOME/rilm/pica2bibtex/fix/type_re.fix --fields ppn,type < $HOME/rilm/pica2bibtex/dmpbms_${Date}.pp > $HOME/rilm/pica2bibtex/data/type_re.csv &&
# Ländercodes der HAs für die Übergabe an die Aufsätze einsammeln
catmandu convert PICA --type plain to CSV --fix $HOME/rilm/pica2bibtex/fix/countrycode.fix < $HOME/rilm/pica2bibtex/dmpbms_${Date}.pp > $HOME/rilm/pica2bibtex/data/countrycodelist.csv &&

# Transformation ausführen.
catmandu -I $HOME/lib convert PICA --type plain to BibTeX --fix $HOME/rilm/pica2bibtex/fix/pica2bibtex.fix --fix $HOME/rilm/pica2bibtex/fix/replace.fix < $HOME/rilm/pica2bibtex/dmpbms_${Date}.pp 1> $HOME/rilm/dmpbms_${Date}.btx 2>/dev/null &&

# BTX-Datei auf mögliche Fehler prüfen
catmandu convert BibTeX to CSV --fields Type,Country,Note,Pages,Number,Volume,Year,Abstract,Abstractor,Series,Crossref,Ausschluss,PPN --fix $HOME/rilm/pica2bibtex/fix/fehlermeldung_bms.fix < $HOME/rilm/dmpbms_${Date}.btx > $HOME/rilm/fehlermeldung_bms_${Date}.csv &&

if [ -f $HOME/rilm/fehlermeldung_bms_${Date}.csv ]; then
   echo "
Der BMS-Abzug im Format Bibtex für RILM befindet sich in der Datei ${green}dmpbms_${Date}.btx${sgr0}.
   
			${cyan}Bitte die Datei ${green}fehlermeldung_bms_${Date}.csv${sgr0} ${cyan}prüfen und bei Bedarf die Daten in dmpbms_${Date}.btx anpassen!!!${sgr0}
   "
   read -p "${cyan}			Mit \"${green}y${cyan}\" bestätigen, wenn die Prüfung beendet und alle Änderungen abgespeichert sind: ${sgr0}" Bestaetigung
   while [[ ! "$Bestaetigung" == y ]]; do
     echo "${red}			Warte auf Bestätigung${sgr0}"
     read -p "			Mit \"${green}y${cyan}\" bestätigen, wenn die Prüfung beendet und alle Änderungen abgespeichert sind: " Bestaetigung
   done 
   echo "Transformation der BMS-Daten erfolgreich abgeschlossen."
   mv $HOME/rilm/fehlermeldung_bms_${Date}.csv ./fehlermeldungen/
   rm $HOME/rilm/dmpbms_${Date}.pp
else
   echo "
   ------------------------------------------------------"
   echo "Transformation abgeschlossen.
Der BMS-Abzug im Format Bibtex für RILM befindet sich in der Datei ${green}dmpbms_${Date}.btx${sgr0}.
" 
fi

sleep 3s

##Abruf und Transformation der OENB-Daten

read -p "

			${cyan}Daten der ÖNB per SRU abrufen und transformieren? \"y/n\": ${sgr0}" Bestaetigung
if [ $Bestaetigung == n ];
   then echo "Transformation beendet"
        echo "Statistik der transformierten BMS-Daten:
"
#        cd $HOME/rilm
		# Erstelle Export-Statistik
        catmandu convert BibTeX to Stat --fix $HOME/rilm/pica2bibtex/fix/stat.fix --fields Aufsätze_Monografien,Rezensionen,Abstracts < $HOME/rilm/dmpbms_${Date}.btx 2>/dev/null | tee $HOME/rilm/pica2bibtex/statistics/rilm_export_statistik_${Date}.csv
        exit 0
fi
if [ $Bestaetigung == y ];
   then echo "Abruf der ÖNB-Daten und Transformation von MARC nach BibTeX wird ausgeführt."
   tmpDate=${Date:0:7}
   tmpDate_I=${tmpDate//-/}
   if [[ "${tmpDate_I:5:1}" == "3" ]]; then
      TEIL1="${tmpDate_I:0:3}"
      Vierte_Stelle=$(( ${tmpDate_I:3:1} - 1))
      TEIL3="${tmpDate_I:4:1}"
      Sechste_Stelle="4"
      DateOENB="${TEIL1}${Vierte_Stelle}${TEIL3}${Sechste_Stelle}"
   elif [[ "${tmpDate_I:5:1}" == "6" ]]; then
      DateOENB=$(( ${tmpDate_I} -5))
   elif [[ "${tmpDate_I:5:1}" == "9" ]]; then
      DateOENB=$(( ${tmpDate_I} -7))
   elif [[ "${tmpDate_I:4:2}" == "12" ]]; then
      DateOENB=$(( ${tmpDate_I} -9))
   else
      echo "${red}Der Zeitstempel der ÖNB-Daten konnte nicht ermittelt werden${sgr0}"
   fi
   echo "Zeitstempel der ÖNB-Daten:" ${green}${DateOENB}${sgr0}
fi

cd ../marc2bibtex &&

# Weitergabe des aktuellen Stempels in die entsprechenden Fixes per $Date
sed -i "s/alma.local_field_980=RILM[0-9]\+/alma.local_field_980=RILM\l$DateOENB/g" ./fix/sru_sort_request.fix &&

#Abrufen der Identifier der Hauptaufnahmen aller mit dem RILM-Stempel gekennzeichneten Datensätze
catmandu convert SRU --base https://obv-at-oenb.alma.exlibrisgroup.com/view/sru/43ACC_ONB --recordSchema marcxml --parser marcxml --query alma.local_field_980=RILM${DateOENB} to CSV --fix ./fix/sru_request.fix --fields ac_number > ./data/oenb.csv &&

# sortiert die Einträge und entfernt Dubletten
grep -P '\d{5,}' ./data/oenb.csv | sort | uniq > ./data/oenb_sort.csv &&
#fügt den Spaltennamen "ac_number" ein
sed -i '1s/^/ac_number\n/' ./data/oenb_sort.csv &&

# Abruf der vollständigen Aufsätze und ihrer Hauptaufnahmen
catmandu convert CSV to Null --fix ./fix/sru_sort_request.fix < ./data/oenb_sort.csv &&
# Zusammenführung der Daten
cat ./data/oenb_coll.mrk ./data/oenb_ha.mrk > ../oenb_${DateOENB}.mrk &&

# BibTeX-Datei auf eventuell fehlende Formschlagwörter (Festschrift/Konferenzschrift) prüfen
catmandu convert MARC --type MARCMaker to CSV --fields Konferenzschrift,Festschrift,Dissertation,Titelzusatz,ID --fix ./fix/formschlagwort_oenb.fix < ../oenb_${DateOENB}.mrk > ../formschlagwort_oenb.csv

if [ -f ../formschlagwort_oenb.csv ]; then
   echo "
			${cyan}Bitte die Datei ${green}formschlagwort_oenb.csv${cyan} prüfen und in der Datei ${green}oenb_${DateOENB}.mrk${cyan} bei Bedarf Formschlagwörter in den Hauptaufnahmen ergänzen.
			Gegebenenfalls vor den Titelzusätzen in Feld 245 \"\$b\" einfügen.
			Danach Datei speichern und schließen.${sgr0}"
fi

read -p "${cyan}			Mit \"${green}y${cyan}\" bestätigen, wenn die Prüfung beendet und alle Änderungen abgespeichert sind: ${sgr0}" Bestaetigung
while [[ ! "$Bestaetigung" == y ]]; do
  echo "${red}Warte auf Bestätigung${sgr0}"
  read -p "${cyan}			Bitte mit \"${green}y${cyan}\" bestätigen, wenn die Datei oenb_${DateOENB}.mrk geschlossen ist und die Transformation fortgeführt werden kann: ${sgr0}" Bestaetigung
done 

echo "Transformation der ÖNB-Daten nach BibTeX wird fortgesetzt."

# Kopiere aktualisierte PICA_Datei in Arbeitsverzeichnis
cp ../oenb_${DateOENB}.mrk ./data/ &&

# Lösche formschlagwort_oenb.csv
if [ -f ../formschlagwort_oenb.csv ]; then
   rm ../formschlagwort_oenb.csv
fi &&

# Liste von ACNummer und type der Hauptaufnahme erstellen
catmandu convert MARC --type MARCMaker to CSV --fix ./fix/type.fix --fields ACNumber,type < ./data/oenb_${DateOENB}.mrk > ./data/type.csv &&
# Liste von ACNummer und Ländercode der Hauptaufnahmen erstellen
catmandu convert MARC --type MARCMaker to CSV --fix ./fix/countrycode.fix < ./data/oenb_${DateOENB}.mrk > ./data/countrycodelist.csv &&
# Liste von ACNummer und Volume der Hauptaufnahmen erstellen
catmandu convert MARC --type MARCMaker to CSV --fix ./fix/volume.fix --fields ACNumber,volume < ./data/oenb_${DateOENB}.mrk > ./data/volume.csv &&

# Transformation der OENB-Daten von MARC nach BibTeX
catmandu -I ../../lib convert MARC --type MARCMaker to BibTeX --fix ./fix/marc2bibtex.fix --fix ./fix/replace.fix < ./data/oenb_${DateOENB}.mrk >> ../dmpbms_${Date}.btx &&

# Prüfung der BibTeX-Daten und Ausgabe einer Fehlerdatei
catmandu convert BibTeX to CSV --fields Type,Country,Note,Pages,Number,Volume,Year,Abstract,Abstractor,Series,Crossref,Ausschluss,PPN --fix ./fix/fehlermeldung_oenb.fix < ../dmpbms_${Date}.btx > ../fehlermeldung_oenb_${DateOENB}.csv &&

if [ -f ../fehlermeldung_oenb_${DateOENB}.csv ]; then
   echo "${cyan}			Bitte die Datei ${green}fehlermeldung_oenb_${DateOENB}.csv${cyan} prüfen und bei Bedarf die Daten in dmpbms_${Date}.btx anpassen!!!${sgr0}"
   read -p "${cyan}			Mit \"${green}y${cyan}\" bestätigen, wenn die Prüfung beendet und alle Änderungen abgespeichert sind: ${sgr0}" Bestaetigung
   while [[ ! "$Bestaetigung" == y ]]; do
     echo "${red}Warte auf Bestätigung${sgr0}"
     read -p "${cyan}			Bitte mit \"${green}y${cyan}\" bestätigen, wenn die Datei oenb_${DateOENB}.mrk geschlossen ist und die Transformation fortgeführt werden kann: ${sgr0}" Bestaetigung
   done 
   echo "Transformation der ÖNB-Daten nach BibTeX wird fortgesetzt."
   mv ../fehlermeldung_oenb*.csv ./fehlermeldungen/
   mv ./data/oenb_${DateOENB}.mrk ./ablage/
   rm ../oenb_${DateOENB}.mrk
else
   echo "
   ------------------------------------------------------"
   echo "Transformation abgeschlossen."
fi
echo "
Die ÖNB-Daten im Format Bibtex für RILM befinden sich in der Datei ${green}dmpbms_${Date}.btx${sgr0}." 

sleep 3s

# Erstelle Export-Statistik
echo "
Statistik der transformierten BMS-Daten:
"
cd .. &&

catmandu convert BibTeX to Stat --fix ./pica2bibtex/fix/stat.fix --fields Aufsätze_Monografien,Rezensionen,Abstracts < dmpbms_${Date}.btx 2>/dev/null | tee ./pica2bibtex/statistics/rilm_export_statistik_${Date}.csv &&

sleep 3s

# Export-Statistik für OENB-BibTeX-Daten 
echo "
Statistik der transformierten ÖNB-Daten:
"
catmandu convert BibTeX to Stat --fix ./marc2bibtex/fix/stat.fix --fields Aufsätze_Monografien,Rezensionen,Abstracts < dmpbms_${Date}.btx 2>/dev/null | tee ./marc2bibtex/statistics/rilm_export_statistik_${DateOENB}.csv &&
echo "
------------------------------------------------------"
echo "Transformation der BMS-Daten und der ÖNB-Daten für RILM beendet.
"
