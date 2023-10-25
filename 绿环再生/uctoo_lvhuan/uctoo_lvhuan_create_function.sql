CREATE OR REPLACE FUNCTION uctoo_lvhuan.getChildrenOrg(orgid character varying)
RETURNS character varying AS $$
DECLARE
    oTemp character varying := '';
    oTempChild character varying := orgid;
BEGIN
    WHILE oTempChild IS NOT NULL LOOP
        oTemp := oTemp || ',' || oTempChild;
        SELECT string_agg(id::text, ',') INTO oTempChild FROM keycloak_group WHERE PARENT_GROUP = ANY(string_to_array(oTempChild, ','));
    END LOOP;

    RETURN oTemp;
END;
$$ LANGUAGE plpgsql;
