WITH realestate AS (
SELECT 
  nextval('mopublic_tmp.t_ili2db_seq') as t_id, a.t_id as gs_t_id, a.nbident, 
  a.nummer, a.egris_egrid, a.vollstaendigkeit, b.flaechenmass,
  CASE
    WHEN d.gueltigereintrag IS NULL THEN d.datum1
    ELSE d.gueltigereintrag
  END AS stand_am,
  2549 as gem_bfs, b.geometrie
FROM 
  dm01_tmp.liegenschaften_lsnachfuehrung as d, 
  dm01_tmp.liegenschaften_grundstueck as a, 
  dm01_tmp.liegenschaften_liegenschaft as b
WHERE b.liegenschaft_von = a.t_id
AND a.entstehung = d.t_id
)
INSERT INTO 
  mopublic_tmp.ownership_realestate 
  (
    t_id, t_ili_tid, identnd, anumber, egris_egrid, completeness, area, state_of, fosnr, geometry
  )
SELECT 
  t_id, uuid_generate_v4(), nbident, nummer, egris_egrid, vollstaendigkeit, 
  flaechenmass, stand_am::timestamp without time zone, gem_bfs, 
  geometrie
FROM realestate;
