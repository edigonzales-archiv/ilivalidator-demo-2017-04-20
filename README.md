# ilivalidator-Demo &mdash; 2017-04-20

## Inhalt

* Kurzintro _ilivalidator_
* Eigene (strengere) Bedingungen
* Eigene Funktionen (Custom Functions)
* <s>Eigene Funktionen programmieren lernen.</s>
* <s>Alle Antworten auf eure Fragen.</s>

## Kurzintro _ilivalidator_

### Einleitung
* "Wir können jetzt INTERLIS-Daten erstellen, sie aber nicht prüfen."
* _ilivalidator_ prüft Modellkonformität einer INTERLIS-Transferdatei.
* Erstinvestition: ~ 80k (swissphoto, Kt. SO und Kt. GL)

### Entwicklung
* Eisenhutinformatik AG
* [https://github.com/claeis/ilivalidator](https://github.com/claeis/ilivalidator) 
* [https://github.com/claeis/iox-ili/](https://github.com/claeis/iox-ili/)
* Entwicklungszeit bis Version 1.0.0 circa 9 Monate.
* [Bug melden](https://github.com/claeis/ilivalidator/issues/39) -> [Fix](https://github.com/claeis/iox-ili/commit/70fdb48aacebbd78de18928a9cde4aa5db0adb9d) -> [Test (Configuration23Test.java)](https://github.com/claeis/iox-ili/commit/70fdb48aacebbd78de18928a9cde4aa5db0adb9d)
* Fragen: [interlis2.ch Forum](http://interlis2.ch)

### Architektur
* Java
* Standalone (CLI und GUI)
* Einsatz als Bibliothek in anderen (Java-)Programmen, z.B. [Webservice](https://interlis2.ch/ilivalidator) / [Quellcode](https://git.sogeo.services/stefan/ilivalidator-spring-boot/src/master/src/ilivalidator/src/main/java/ch/so/agi/interlis/services/IlivalidatorService.java).

### Modellkonformität prüfen
Daten der amtlichen Vermessung im Datenmodell [MOpublic](http://models.geo.admin.ch/V_D/MOpublic95_ili2_v1.3.ili) (ili23). Es handelt sich dabei nicht um einen vollständigen Datensatz. Fehler wurden absichtlich eingebaut.

```
java -jar ../apps/ilivalidator-master/ilivalidator.jar --help
```

Prüfung einer INTERLIS-Transferdatei:

```
java -jar ../apps/ilivalidator-master/ilivalidator.jar ../examples/01/mopublic.xtf
```

Resultat auf Konsole: `Info: ...validation done`

Prüfung einer INTERLIS-Transferdatei *mit* Fehler:

```
java -jar ../apps/ilivalidator-master/ilivalidator.jar ../examples/01/mopublic_error.xtf
```

Resultat auf Konsole: `Info: ...validation failed`. Der eigentliche Fehler wird auch in der Konsole ausgegeben: Zeilenummer in XTF-Datei und TID.

Mit `--log` kann in eine Log-Datei geschrieben werden. Mit `--xtflog` kann in eine sehr einfach gehaltene [INTERLIS-Logdatei](http://models.interlis.ch/models/tools/IliVErrors.ili) geschrieben werden (inkl. Lokalisation des Fehlers):

```
java -jar ../apps/ilivalidator-master/ilivalidator.jar --xtflog error_log.xtf ../examples/01/mopublic_error.xtf
```

Fehler können zu Warnungen heruntergestuft werden oder komplett ausgeschaltet werden. Gesteuert über eine Konfigurationsdatei und Parameter `--config`:

```
java -jar ../apps/ilivalidator-master/ilivalidator.jar --config ../examples/01/mopublic.toml ../examples/01/mopublic_error.xtf
```


Viele Informationen finden sich in der [Dokumentation](https://github.com/claeis/ilivalidator/blob/master/docs/ilivalidator.rst).


## Eigene (strengere) Bedingungen

Das Modell lässt bei den Fixpunkten Nummern mit maximal 12 Zeichen zu. Im Kanton Solothurn sind z.B. nur 8 Zeichen erlaubt.

Frage: Wie und wo würdet ihr diese zusätzliche Bedingung definieren/steuern/schreiben wollen?

Man schreibt einfach einen weiteren Constraint in das Modell. INTERLIS definiert einen Strauss voll von Standardfunktionen, so z.B. auch `INTERLIS.len()` (siehe [Referenzhandbuch Kapitel 2.14](http://interlis.ch/interlis2/docs23/ili2-refman_2006-04-13_d.pdf)). Diese Funktion liefert die Länge eines Textes zurück. Der zusätzliche Constraint sieht nun wie folgt aus:

```
MANDATORY CONSTRAINT (INTERLIS.len (Number)) == 8;
```

Wo schreibe ich das hin? Das Modell liegt bei swisstopo im Repository.

Wir verwenden INTERLIS-Views ([Rererenzhandbuch Kapitel 2.15](http://interlis.ch/interlis2/docs23/ili2-refman_2006-04-13_d.pdf)). Dh. wir schreiben ein [zweites Modell](examples/02/mopublic_check.ili) (&laquo;Check-Modell&raquo;) und dort drin definieren wir eine Sicht auf die gewünschte Klasse des Original-Modells. Für diese Sicht können wir dann beliebig viele zusätzliche Constraints definieren (ohne das Original-Modell zu verändern).

Die Syntaxprüfung unseres Check-Modells erfolgt bequem mit dem INTERLIS-Compiler:

```
java -jar ../apps/ili2c-4.7.2/ili2c.jar ../examples/02/MOpublic_Check.ili
```

In der [Konfigurationsdatei](examples/02/mopublic.toml) muss noch das zusätzliche Modell registriert werden. Der Programmaufruf ist gleich geblieben:

```
java -jar ../apps/ilivalidator-master/ilivalidator.jar --config ../examples/02/mopublic.toml ../examples/02/mopublic_number_length.xtf
```

Bravo, Fehler gefunden aber völlig intransparent/unverständlich für den Menschen: `Constraint1`.

Fehlermeldung und Constraintname können mittels INTERLIS-Metaattributen gesteuert werden:

```
java -jar ../apps/ilivalidator-master/ilivalidator.jar --config ../examples/03/mopublic.toml ../examples/03/mopublic_number_length.xtf
```

Resultat sieht doch schon besser aus.



## Weitere Informationen
* Doku
* iox/ili test-ilis...




