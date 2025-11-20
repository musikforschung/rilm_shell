<details>

<summary>us English version (click here)</summary>

# rilm.sh

Transformation of bibliographic data from PICA and MARC to BibTeX for RILM

The German editorial office of the Répertoire International de Littérature Musicale (RILM) is located at the Staatliches Institut für Musikforschung (SIM). As such, the SIM transmits all entries of the [Bibliographie des Musikschrifttums](https://www.musikbibliographie.de/) (BMS online) published in Germany to the central editorial office of [RILM Abstracts of Music Literature](https://www.rilm.org/abstracts/) on a quarterly basis. In addition, the entries reported by the editorial team at the Austrian National Library are transferred and delivered to RILM. The bibliographic data of the Austrian RILM editorial team is retrieved via the SRU interface in MARC format and must be transformed into BibTeX format for further processing at the RILM central editorial office. SIM uses the command-line tool Catmandu for this purpose. Further information about Catmandu is available here https://librecat.org/Catmandu.

# Files description

* [rilm.sh](https://github.com/musikforschung/rilm_shell/blob/main/rilm.sh) Bash script to run [pica2bibtex](https://github.com/musikforschung/pica2bibtex) and [marc2bibtex](https://github.com/musikforschung/marc2bibtex) successively and to put the PICA data from BMS online and the MARC data from Austrian National Library into one BibTeX file.  

# Required Catmandu modules

* [Catmandu::PICA](https://metacpan.org/dist/Catmandu-PICA)
* [Catmandu::MARC](https://metacpan.org/pod/Catmandu::MARC)
* [Catmandu::BibTeX](https://metacpan.org/pod/Catmandu::BibTeX)
* [BibTeX.pm](https://github.com/musikforschung/Exporter/blob/main/BibTeX.pm)

# Required fixes

*[pica2bibtex](https://github.com/musikforschung/pica2bibtex)
*[marc2bibtex](https://github.com/musikforschung/marc2bibtex)

# Authors

René Wallor, wallor at sim.spk-berlin.de


</details>

---

<details open>

<summary>DE Deutsche Version</summary>


# rilm.sh

Transformation bibliographischer Daten aus dem Format PICA und MARC in das Format BibTeX für RILM

Am Staatlichen Institut für Musikforschung (SIM) befindet sich die deutsche Redaktion des Répertoire International de Littérature Musicale (RILM). Als diese übermittelt das SIM vierteljährlich alle in Deutschland erscheinenden Einträge der [Bibliographie des Musikschrifttums](https://www.musikbibliographie.de/) (BMS online) an die Zentralredaktion von [RILM Abstracts of Music Literature](https://www.rilm.org/abstracts/). Zusätzlich werden die gemeldeten Einträge der Redaktion an der Österreichischen Nationalbibliothek übernommen und an RILM geliefert. Die bibliographischen Daten der österreichischen RILM-Redaktion werden per SRU-Schnittstelle im MARC-Format abgerufen und müssen für die Weiterverarbeitung in der RILM-Zentralredaktion in das Format BibTeX transformiert werden. Dafür nutzt das SIM das Kommandozeilentool Catmandu. Weitere Informationen zu Catmandu gibt hier https://librecat.org/Catmandu. 

# Beschreibung der Dateien

[rilm.sh](https://github.com/musikforschung/rilm_shell/blob/main/rilm.sh) Bash-Skript zur sukzessiven Ausführung von [pica2bibtex](https://github.com/musikforschung/pica2bibtex) und [marc2bibtex](https://github.com/musikforschung/marc2bibtex) für die Transformation von PICA-Daten aus BMS online und von MARC-Daten der Österreichischen Nationalbibliothek für RILM und ihre Zusammenführung in eine BibTeX-Datei. 

# Erforderliche Catmandu-Module

* [Catmandu::PICA](https://metacpan.org/dist/Catmandu-PICA)
* [Catmandu::MARC](https://metacpan.org/pod/Catmandu::MARC)
* [Catmandu::BibTeX](https://metacpan.org/pod/Catmandu::BibTeX)
* [BibTeX.pm](https://github.com/musikforschung/Exporter/blob/main/BibTeX.pm)

# Erforderliche fixes

*[pica2bibtex](https://github.com/musikforschung/pica2bibtex)
*[marc2bibtex](https://github.com/musikforschung/marc2bibtex)

# Autoren

René Wallor, wallor at sim.spk-berlin.de

</details>

---