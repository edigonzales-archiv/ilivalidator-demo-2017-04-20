WITH bb AS (
SELECT 
  a.t_id, 2549 as bfsnr, a.art,
  CASE
    WHEN b.gueltigereintrag IS NULL THEN b.datum1
    ELSE b.gueltigereintrag
  END AS stand_am,
  CASE
    WHEN a.qualitaet IS NULL THEN 0
    ELSE a.qualitaet
  END AS qualitaet, a.geometrie
FROM dm01_tmp.bodenbedeckung_boflaeche a, dm01_tmp.bodenbedeckung_bbnachfuehrung b
WHERE a.entstehung = b.t_id
),
gebnr AS (
SELECT gebaeudenummer_von, gwr_egid
FROM dm01_tmp.bodenbedeckung_gebaeudenummer
)
INSERT INTO 
  mopublic_tmp.land_cover_lcsurface 
  (
    t_id, t_ili_tid, quality, atype, regbl_egid, state_of, fosnr, geometry
  )
SELECT 
 nextval('mopublic_tmp.t_ili2db_seq') AS t_id, uuid_generate_v4(), 
 bb.qualitaet, bb.art, gebnr.gwr_egid,
 bb.stand_am::timestamp without time zone as stand_am,
 bb.bfsnr, bb.geometrie
FROM bb LEFT JOIN gebnr ON bb.t_id = gebnr.gebaeudenummer_von;

