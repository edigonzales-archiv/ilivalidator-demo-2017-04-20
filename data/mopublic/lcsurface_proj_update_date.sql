UPDATE 
  mopublic_tmp.land_cover_lcsurfaceproj
SET 
  state_of = now()
;

UPDATE 
  mopublic_tmp.land_cover_lcsurfaceproj
SET 
  state_of = '2012-01-01'::timestamp without time zone
WHERE
  t_id = (
    SELECT
      t_id
    FROM 
      mopublic_tmp.land_cover_lcsurfaceproj
    LIMIT 1
    )
;