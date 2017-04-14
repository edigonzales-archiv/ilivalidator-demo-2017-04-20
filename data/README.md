## AV-Daten importieren (DM01)
```
java -jar ../apps/ili2pg-3.7.0/ili2pg.jar --dbhost localhost --dbdatabase xanadu2 --dbusr stefan --dbpwd ziegler12 --dbschema dm01_tmp --sqlEnableNull --disableValidation --nameByTopic --createEnumColAsItfCode --defaultSrsCode 2056 --models DM01AVCH24LV95D --import ch_254900.itf
```

## MOpublic-Schema anlegen
```
java -jar ../apps/ili2pg-3.7.0/ili2pg.jar --dbhost localhost --dbdatabase xanadu2 --dbusr stefan --dbpwd ziegler12 --dbschema mopublic_tmp --sqlEnableNull --disableValidation --nameByTopic --defaultSrsCode 2056  --models MOpublic95_ili2_v13 --schemaimport
```

## Datenumbau DM01 -> MOpublic

Projektierte Gebäude werden gefaked aus Bodenbedeckung. Es werden zwei Gebäude kopiert und anschliessend wird das `state_of`-Datum auf `now()` gesetzt. Ein Datum (`LIMIT 1`) wird auf 2012 zurück gesetzt.

```
psql -d xanadu2 -f control_point.sql

psql -d xanadu2 -f lcsurface.sql

psql -d xanadu2 -f lcsurface_proj.sql

psql -d xanadu2 -f lcsurface_proj_update_date.sql
```

## MOpublic exportieren
```
java -jar ../apps/ili2pg-3.7.0/ili2pg.jar --dbhost localhost --dbdatabase xanadu2 --dbusr stefan --dbpwd ziegler12 --dbschema mopublic_tmp --sqlEnableNull --disableValidation --nameByTopic --defaultSrsCode 2056  --models MOpublic95_ili2_v13 --export mopublic.xtf
```

## XTF formatieren
```
xmllint --format mopublic.xtf -o mopublic.xtf
```
