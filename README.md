# ilivalidator-Demo &mdash; 2017-04-20

## Inhalt

* Kurzintro _ilivalidator_
* Eigene (strengere) Bedingungen
* Eigene Funktionen (Custom Functions)
* <s>Programmieren von eigenen Funktionen.</s>
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
java -jar ../apps/ilivalidator-master/ilivalidator.jar ../examples/01/mopublic_errors.xtf
```

Resultat auf Konsole: `Info: ...validation failed`. Der eigentliche Fehler wird auch in der Konsole ausgegeben: Zeilenummer in XTF-Datei und TID.

Mit `--log` kann in eine Log-Datei geschrieben werden. Mit `--xtflog` kann in eine sehr einfach gehaltene [INTERLIS-Logdatei](http://models.interlis.ch/models/tools/IliVErrors.ili) geschrieben werden (inkl. Lokalisation des Fehlers):

```
java -jar ../apps/ilivalidator-master/ilivalidator.jar --xtflog error_log.xtf ../examples/01/mopublic_errors.xtf
```

Fehler können zu Warnungen heruntergestuft werden oder komplett ausgeschaltet werden. Gesteuert über eine Konfigurationsdatei und Parameter `--config`:

```
java -jar ../apps/ilivalidator-master/ilivalidator.jar --config ../examples/01/mopublic.toml ../examples/01/mopublic_errors.xtf
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
java -jar ../apps/ilivalidator-master/ilivalidator.jar --config ../examples/02/mopublic.toml ../examples/02/mopublic_errors.xtf
```

Bravo, Fehler gefunden aber völlig intransparent/unverständlich für den Menschen: `Constraint1`.

Fehlermeldung und Constraintname können mittels INTERLIS-Metaattributen gesteuert werden:

```
java -jar ../apps/ilivalidator-master/ilivalidator.jar --config ../examples/03/mopublic.toml ../examples/03/mopublic_errors.xtf
```

Resultat sieht doch schon besser aus.

Im MOpublic-Datenmodell sind die typischen AREA-Geometrien &laquo;nur&raquo; noch SURFACE-Geometrien. Will man jetzt doch prüfen, ob sich die Geometrien einiger Klassen nicht überlappen, kann man die `INTERLIS.areAreas()`-Funktion verwenden:
 
```
SET CONSTRAINT INTERLIS.areAreas(ALL, UNDEFINED, >> Geometry);
```

Die Prüfung ohne diesen zusätzlichen Constraint liefert keinen zusätzlichen Fehler in den Daten.

```
java -jar ../apps/ilivalidator-master/ilivalidator.jar  ../examples/04/mopublic_errors.xtf
```

Jetzt mit zusätzlichen Constraint in unserem Check-Modell. Dafür muss man wieder die Konfigurationsdatei mitliefern.

```
java -jar ../apps/ilivalidator-master/ilivalidator.jar  --config ../examples/04/mopublic.toml ../examples/04/mopublic_errors.xtf
```

Upsi... Nach ein paar Minuten wird kein Fehler gefunden -> [Bug](https://github.com/claeis/ilivalidator/issues/50) im Programm.

Mit den INTERLIS-Standardfunktionen und Views kommt man schon relativ weit, wenn man strengere Bedingungen formulieren und prüfen will. Es lohnt sich das Kapitel 2.14 und 2.15 des Referenzhandbuches zu lesen und vor allem die [Beispiel-Modelle](https://github.com/claeis/iox-ili/tree/master/src/test/data/validator) für die Tests von ilivalidator resp. iox-ili. Anhand der Beispiele bekommt man sofort ein Gefühl, was bereits geht resp. was möglich ist.

## Eigene Funktionen (Custom Functions)

Was aber wenn die Standardfunktionen nicht mehr reichen? Oder wenn man die zu prüfenden Daten mit Referenzdaten vergleichen will? 

Man kann _ilivalidator_ beliebig erweitern, indem  man selber Java-Klassen schreibt. Konkret muss man ein bestimmtes [Interface](https://github.com/claeis/iox-ili/blob/master/src/main/java/ch/interlis/iox_j/validator/InterlisFunction.java) implementieren.

Jede Funktion erhält einen qualifizierten INTERLIS-Namen. Das heisst jetzt nicht, dass die Funktion nur für ein Modell funktionert, sondern man macht sich ein Funktions-Modell und importiert das jeweils in sein Check-Modell, wenn man eine bestimmte Funktion braucht. 

### Eigene Funktion
In der amtlichen Vermessung verwalten wir die projektierten Gebäude. Ist so ein Eintrag älter als drei Jahre (und dementsprechend keine richtiges Gebäude gebaut), wollen wir dieses projektierte Gebäude wieder aus dem Datensatz entfernt haben. Wir brauchen nun eine Funktion, die das Erfassungsdatum (das im AV-Datensatz geführt wird) mit dem Datum von heute vergleichen und einen Fehler melden, falls die Differenz grösser drei Jahre ist.

Gesagt, getan: [AgeYearsIoxPlugin.java](https://git.sogeo.services/stefan/ilivalidator-extensions/src/e6ef0a6ff2bd15f0449451c5978906026d9a1f7a/src/ilivalidator-extensions/src/main/java/org.catais.ilivalidator.ext/AgeYearsIoxPlugin.java)

Die Java-Klassen müssen jetzt von _ilivalidator_ gefunden werden. Standardmässig sucht _ilivalidator_ in einem `plugins`-Verzeichnis in dem Applikationsverzeichnis.

In unserem Check-Modell muss ich, wie bereits erwähnt, mein Funktions-Modell importieren. Anschliessend natürlich den Constraint definieren.

Das Resultat des folgenden Aufrufs listet ein projektiertes Gebäude auf, das älter als drei Jahre ist:

```
java -jar ../apps/ilivalidator-master/ilivalidator.jar  --config ../examples/05/mopublic.toml ../examples/05/mopublic_errors.xtf
```

### Vergleich mit Referenzdaten
Momentan trendy sind Abgleiche zwischen der amtlichen Vermessung und dem GWR. In beiden Registern wird der EGID verwaltet. Das ist auch gleichbedeutent mit Widersprüchen. Dank der Erweiterbarkeit kann ich mir jetzt eine INTERLIS-Funktion schreiben, die jeden EGID aus den Daten der amtlichen Vermessung mit einem Referenzdatensatz vergleicht. Nehmen wir mal an - rein hypothetisch -, dass dieser Referenzdatensatz der GWR ist. Am einfachsten gelangt mit mit der swisstopo API an diese Daten. Ist natürlich nicht wirklich das Gelbe vom Ei aber für die Demo reicht es:
 
* [Dokumentation / Beschreibung](https://api3.geo.admin.ch/services/sdiservices.html#find)
* [Beispiel-Request](https://api3.geo.admin.ch/rest/services/api/MapServer/find?layer=ch.bfs.gebaeude_wohnungs_register&searchText=367267&searchField=egid&returnGeometry=false&contains=false)

Programmiert war die neue [INTERLIS-Funktion](https://git.sogeo.services/stefan/ilivalidator-extensions/src/112388c2fbd21466896b78f1cf27390259ae0985/src/ilivalidator-extensions/src/main/java/org.catais.ilivalidator.ext/Check4GWRIoxPlugin.java) rasch. Tricky war hingegen, dass sie zusätzlichen Java-Bibliotheken benötig. _ilivalidator_ muss diese beim Verwenden der Funktion auch finden. Aus diesem Grund muss der Programmaufruf anders sein:

```
java -cp  '../apps/ilivalidator-master-http/ilivalidator.jar:../apps/ilivalidator-master-http/libs/*:../apps/ilivalidator-master-http/plugins/*' org.interlis2.validator.Main --config ../examples/06/mopublic.toml  ../examples/06/mopublic_errors.xtf
```

Ich hoffe, dass das grundstätzlich noch eleganter geht. Das Check- und Funktions-Modell habe ich bereits angepasst. Die Prüfung meldet einen unbekannten EGID in den Daten der amtlichen Vermessung.

**ACHTUNG:** Nur zu Testzwecken verwenden. Nicht für die Produktion.

Es muss natürlich nicht immer gleich ein Webservice sein den man anzapft. In vielen Fällen dürfte es wahrscheinlich eine lokale Datei und/oder eine Datenbank sein.

## TODO / Ausprobieren / Testen / Überlegen
* Sauberes Logging aus den Custom Functions.
* `SET CONSTRAINT WHERE ...`
* `BAG/LIST OF` (siehe `GB2AV`)
* Vererbungen (bereits angetestet mit `GB2AV`)
* isInteger: "mit Pfad"
* Bedingungen aus assozierten Objekten: Nutzungstyp ist in Klasse A erfasst. Geometrie in Klasse B. Assoziation zwischen beiden Klassen. Prüfung auf Areas für typ="XXX"
* elementCount(): von typ=XX darf es genau YY Elemente haben.
* Ist-/Soll-Möglichkeiten von Views
* Parameterübergabe durch Benutzer. Wert des Parameters ist in Constraints und Custom Functions verfügbar ("System.xxx")
* Rückgabewert von Funktionen in Messages
* Dokumentation der Custom Functions
* 




