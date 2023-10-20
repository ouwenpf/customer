CREATE OR REPLACE FUNCTION keycloak.getChildrenOrg(orgid VARCHAR(4000))
RETURNS VARCHAR(4000) AS $$
DECLARE
    oTemp VARCHAR(4000);
    oTempChild VARCHAR(4000);
BEGIN
    oTemp := '';
    oTempChild := orgid;

    WHILE oTempChild IS NOT NULL LOOP
        oTemp := oTemp || ',' || oTempChild;
        SELECT string_agg(id, ',') INTO oTempChild
        FROM KEYCLOAK_GROUP
        WHERE oTempChild = ANY(string_to_array(PARENT_GROUP, ','));

        IF oTempChild IS NULL THEN
            EXIT;
        END IF;
    END LOOP;

    RETURN oTemp;
END;
$$ LANGUAGE plpgsql;