WITH lfp2 AS (
SELECT 
  a.t_id, 2 as category, a.nbident AS identnd, nummer AS anumber, 
  geometrie AS geometry, lagegen AS plan_accuracy, hoehegeom AS geom_alt, 
  hoehegen AS alt_accuracy,
  CASE
    WHEN a.punktzeichen IS NULL THEN 7
    ELSE a.punktzeichen
  END as mark,
  CASE
    WHEN b.gueltigereintrag IS NULL THEN b.datum1
    ELSE b.gueltigereintrag
  END AS state_of,
2549 as fosnr
FROM dm01_tmp.fixpunktekatgrie2_lfp2 as a,
     dm01_tmp.fixpunktekatgrie2_lfp2nachfuehrung as b
WHERE a.entstehung = b.t_id
),
lfp3 AS (
SELECT 
  a.t_id, 4 as category, a.nbident AS identnd, nummer AS anumber, 
  geometrie AS geometry, lagegen AS plan_accuracy, hoehegeom AS geom_alt, 
  hoehegen AS alt_accuracy,
  CASE
    WHEN a.punktzeichen IS NULL THEN 7
    ELSE a.punktzeichen
  END as mark,
  CASE
    WHEN b.gueltigereintrag IS NULL THEN b.datum1
    ELSE b.gueltigereintrag
  END AS state_of,
2549 as fosnr
FROM dm01_tmp.fixpunktekatgrie3_lfp3 as a,
     dm01_tmp.fixpunktekatgrie3_lfp3nachfuehrung as b
WHERE a.entstehung = b.t_id
)
INSERT INTO 
  mopublic_tmp.control_points_control_point 
  (
    t_id, t_ili_tid, category, identnd, anumber, plan_accuracy, geom_alt,
    alt_accuracy, mark, state_of, fosnr, geometry
  )
SELECT 
  nextval('mopublic_tmp.t_ili2db_seq') AS t_id, uuid_generate_v4(), category, 
  identnd, anumber, plan_accuracy, geom_alt, alt_accuracy, mark,
  state_of::timestamp without time zone, fosnr, geometry
FROM
(
 SELECT * FROM lfp2
 UNION ALL
 SELECT * FROM lfp3
) as fp;


