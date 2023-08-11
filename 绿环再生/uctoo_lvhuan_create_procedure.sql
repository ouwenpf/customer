CREATE OR REPLACE PROCEDURE uctoo_lvhuan.province_wall_report()
LANGUAGE plpgsql
AS $$
DECLARE 
    nowdate date := NOW() - INTERVAL '1 day';
    report_row RECORD;
BEGIN
    INSERT INTO uct_day_wall_report(adcode, weight, availability, rubbish, rdf, carbon, box, customer_num, report_date)
    SELECT
        ad.adcode,
        COALESCE(weight, 0) AS weight,
        COALESCE(availability, 0) AS availability,
        COALESCE(rubbish, 0) AS rubbish,
        COALESCE(rdf, 0) AS rdf,
        COALESCE(carbon, 0) AS carbon,
        COALESCE(box, 0) AS box,
        COALESCE(customer.customer_num, 0) AS customer_num,
        nowdate AS report_date
    FROM
        uct_adcode ad
        LEFT JOIN (
            SELECT
                ad.adcode,
                ROUND(SUM(FQty), 2) AS weight,
                ROUND(SUM(CASE WHEN c.name = '低值废弃物' THEN FQty ELSE 0 END) / SUM(FQty), 2) AS availability,
                ROUND(SUM(CASE WHEN c.name = '低值废弃物' THEN FQty ELSE 0 END), 2) AS rubbish,
                ROUND(SUM(CASE WHEN c.name = '低值废弃物' THEN FQty ELSE 0 END) / SUM(FQty) * 4.2, 2) AS rdf,
                ROUND(SUM(FQty * c2.carbon_parm), 2) AS carbon,
                box.box
            FROM
                Trans_main_table mt
                JOIN Trans_main_table mt2 ON mt.FInterId = mt2.FInterId
                                          AND mt2.FTranType = 'PUR'
                                          AND mt2.FDate > '2018-09-30'
                                          AND mt2.FDate = nowdate
                JOIN uct_waste_purchase p ON mt.FBillNo = p.order_id
                JOIN uct_waste_customer_factory cf ON cf.id = p.factory_id
                JOIN uct_adcode ad ON ad.name = cf.province
                JOIN Trans_assist_table at ON mt.FInterID = at.FinterID
                                          AND mt.FTranType = at.FTranType
                JOIN uct_waste_cate c ON c.id = at.FItemID
                JOIN uct_waste_cate c2 ON c.parent_id = c2.id
                LEFT JOIN (
                    SELECT
                        ad.adcode,
                        SUM(FUseCount) AS box
                    FROM
                        Trans_main_table mt
                        JOIN uct_waste_purchase p ON mt.FInterID = p.id
                        JOIN uct_waste_customer_factory cf ON cf.id = p.factory_id
                        JOIN uct_adcode ad ON ad.name = cf.province
                        JOIN Trans_materiel_table materiel ON materiel.FInterID = mt.FInterID
                        JOIN uct_materiel materiel2 ON materiel.FMaterielID = materiel2.id
                                                  AND materiel.FTranType IN ('PUR', 'SOR')
                                                  AND materiel2.name = '分类箱'
                    WHERE
                        mt.FDate > '2018-09-30'
                        AND mt.FDate = nowdate
                        AND mt.FTranType = 'PUR'
                        AND mt.FSaleStyle IN ('0', '1')
                        AND mt.FCorrent = '1'
                        AND mt.FCancellation = '1'
                        AND mt.FRelateBrID != 7
                    GROUP BY
                        cf.province, cf.city
                ) box ON box.adcode = ad.adcode
            WHERE
                mt.FTranType IN ('SOR', 'SEL')
                AND mt.FSaleStyle IN ('0', '1')
                AND mt.FCorrent = '1'
                AND mt.FCancellation = '1'
                AND mt.FRelateBrID != 7
            GROUP BY
                cf.province
        ) data ON ad.adcode = data.adcode
        LEFT JOIN (
            SELECT
                ad.adcode,
                COUNT(*) AS customer_num
            FROM
                uct_up up
                JOIN uct_adcode ad ON up.company_province = ad.name
            WHERE
                first_business_time = nowdate
            GROUP BY
                company_province
        ) customer ON customer.adcode = ad.adcode
    WHERE
        RIGHT(ad.adcode, 4) = '0000';

    FOR report_row IN (SELECT * FROM uct_accumulate_wall_report) LOOP
        UPDATE uct_accumulate_wall_report
        SET 
            weight = data.weight,
            availability = data.availability,
            rubbish = data.rubbish,
            rdf = data.rdf,
            carbon = data.carbon,
            box = data.box,
            customer_num = data.customer_num
        FROM (SELECT
                ad.adcode,
                COALESCE(weight, 0) AS weight,
                COALESCE(availability, 0) AS availability,
                COALESCE(rubbish, 0) AS rubbish,
                COALESCE(rdf, 0) AS rdf,
                COALESCE(carbon, 0) AS carbon,
                COALESCE(box, 0) AS box,
                COALESCE(customer.customer_num, 0) AS customer_num
            FROM
                uct_adcode ad
                LEFT JOIN (
                    SELECT
                        ad.adcode,
                        ROUND(SUM(FQty), 2) AS weight,
                        ROUND(SUM(CASE WHEN c.name = '低值废弃物' THEN FQty ELSE 0 END) / SUM(FQty), 2) AS availability,
                        ROUND(SUM(CASE WHEN c.name = '低值废弃物' THEN FQty ELSE 0 END), 2) AS rubbish,
                        ROUND(SUM(CASE WHEN c.name = '低值废弃物' THEN FQty ELSE 0 END) / SUM(FQty) * 4.2, 2) AS rdf,
                        ROUND(SUM(FQty * c2.carbon_parm), 2) AS carbon,
                        box.box
                    FROM
                        Trans_main_table mt
                        JOIN Trans_main_table mt2 ON mt.FInterId = mt2.FInterId
                                                  AND mt2.FTranType = 'PUR'
                                                  AND mt2.FDate > '2018-09-30'
                    JOIN  uct_waste_purchase p ON mt.FBillNo = p.order_id
                    JOIN  uct_waste_customer_factory cf ON cf.id = p.factory_id   
                    JOIN uct_adcode ad ON ad.name =  cf.city    
                    JOIN Trans_assist_table at ON mt.FInterID = at.FinterID  
                                              AND  mt.FTranType = at.FTranType   
                    JOIN uct_waste_cate c ON  c.id = at.FItemID  
                    JOIN  uct_waste_cate c2 ON c.parent_id = c2.id

                    LEFT JOIN (
                        SELECT
                            ad.adcode,
                            SUM(FUseCount) AS box
                        FROM
                            Trans_main_table mt
                            JOIN  uct_waste_purchase p ON mt.FInterID = p.id  
                            JOIN  uct_waste_customer_factory cf  ON cf.id = p.factory_id   
                            JOIN uct_adcode ad ON ad.name =  cf.city 
                            JOIN Trans_materiel_table materiel ON materiel.FInterID = mt.FInterID  
                            JOIN uct_materiel materiel2 ON materiel.FMaterielID = materiel2.id 
                                                      AND materiel.FTranType IN ('PUR','SOR') 
                                                      AND materiel2.name = '分类箱'  
                        WHERE 
                            mt.FDate > '2018-9-30' 
                            AND mt.FTranType = 'PUR' 
                            AND  mt.FSaleStyle IN ('0','1')  
                            AND  mt.FCorrent = '1' 
                            AND mt.FCancellation = '1'  
                            AND mt.FRelateBrID != 7  
                        GROUP BY 
                            cf.province, cf.city 
                    ) box ON box.adcode = ad.adcode
                    WHERE
                        mt.FTranType IN ('SOR','SEL') 
                        AND mt.FSaleStyle IN ('0','1')  
                        AND  mt.FCorrent = '1' 
                        AND mt.FCancellation = '1'  
                        AND mt.FRelateBrID != 7  
                    GROUP BY 
                        cf.province, cf.city 
                ) data ON ad.adcode = data.adcode
                LEFT JOIN (
                    SELECT 
                        ad.adcode , 
                        COUNT(*) AS customer_num 
                    FROM 
                        uct_up up 
                        JOIN uct_adcode ad ON up.company_city = ad.name 
                    GROUP BY 
                        company_province, company_city
                ) customer ON customer.adcode = ad.adcode
            WHERE
                RIGHT(ad.adcode,4) != '0000' 
                AND RIGHT(ad.adcode,2) = '00'
        ) data WHERE uct_accumulate_wall_report.adcode = report_row.adcode;
    END LOOP;
END;
$$;



CREATE OR REPLACE PROCEDURE uctoo_lvhuan.cursor_test()
LANGUAGE plpgsql
AS $$
DECLARE
    done BOOLEAN := FALSE;
    pid INT;
    cur1 CURSOR FOR SELECT id FROM uct_admin WHERE id = 2;
    cur2 CURSOR FOR SELECT id FROM uct_admin WHERE id = 3;
BEGIN
    START TRANSACTION;

    OPEN cur1;
    FETCH cur1 INTO pid;

    IF FOUND THEN
        RAISE NOTICE 'pid for id 2: %', pid;
    END IF;

    CLOSE cur1;

    OPEN cur2;
    FETCH cur2 INTO pid;

    IF FOUND THEN
        RAISE NOTICE 'pid for id 3: %', pid;
    END IF;

    CLOSE cur2;

    COMMIT;
END;
$$;


CREATE OR REPLACE PROCEDURE uctoo_lvhuan.edit_materiel_num(
    INOUT o_rv INTEGER,
    INOUT o_err VARCHAR(200)
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_FInterID INT;
    v_order_id VARCHAR(20);
    v_number INT;
    v_meta_id INT;
    v_meta_price FLOAT;
    v_meta_amount FLOAT;
    v_money_all INT;
    errno INT;
    report RECORD;
BEGIN
    o_rv := 0;
    o_err := '';

    -- Define a cursor for the query
    DECLARE report_cursor CURSOR FOR 
        SELECT FInterID, order_id, meta_id, number, meta_price, meta_amount 
        FROM uct_apply_for_material_temp 
        WHERE state = 2;

    BEGIN
        -- Open the cursor
        OPEN report_cursor;

        -- Loop over the rows fetched by the cursor
        LOOP
            -- Fetch the next row into the record variable "report"
            FETCH report_cursor INTO report;
            
            -- Exit the loop if no more rows to fetch
            EXIT WHEN NOT FOUND;

            v_FInterID := report.FInterID;
            v_order_id := report.order_id;
            v_meta_id := report.meta_id;
            v_number := report.number;
            v_meta_price := report.meta_price;
            v_meta_amount := report.meta_amount;

            -- Start transaction
            BEGIN
                START TRANSACTION;

                -- Initialize errno
                errno := 0; 
                
                -- Insert into Trans_materiel_table
                INSERT INTO Trans_materiel_table (
                    FInterID,
                    FTranType,
                    FEntryID,
                    FMaterielID,
                    FUseCount,
                    FPrice,
                    FMeterielAmount,
                    FMeterieltime,
                    red_ink_time,
                    is_hedge,
                    revise_state
                ) VALUES (
                    v_FInterID,
                    'PUR',
                    0,
                    v_meta_id,
                    v_number,
                    v_meta_price,
                    v_meta_amount,
                    EXTRACT(EPOCH FROM NOW())::INT,
                    NOW(),
                    0,
                    2
                );
                
                -- Set errno to 1
                errno := 1;

                -- Calculate v_money_all
                SELECT SUM(FMeterielAmount) INTO v_money_all 
                FROM Trans_materiel_table 
                WHERE FInterID = v_FInterID 
                AND FTranType IN ('SOR','PUR');

                -- Update Trans_main_table
                UPDATE Trans_main_table 
                SET TalSecond = v_money_all,
                    is_hedge = 1,
                    red_ink_time = NOW()
                WHERE FInterID = v_FInterID 
                AND FTranType = 'SOR'
                AND FSaleStyle <> 1;
                
                -- Set errno to 2
                errno := 2;

                -- Update uct_apply_for_material_temp
                UPDATE uct_apply_for_material_temp 
                SET state = 1
                WHERE FInterID = v_FInterID;
                
                -- Set errno to 3
                errno := 3;

                -- Commit the transaction
                COMMIT;

                -- Check errno
                IF errno = 3 THEN
                    o_rv := 200;
                    o_err := '处理成功.';
                END IF;
            EXCEPTION
                WHEN OTHERS THEN
                    ROLLBACK;
                    RAISE NOTICE 'Error in loop: %', SQLERRM;
                    o_rv := -1;
                    o_err := '处理失败.';
                    EXIT;
            END;
        END LOOP;

        -- Close the cursor
        CLOSE report_cursor;
    END;
END;
$$;


CREATE OR REPLACE PROCEDURE uctoo_lvhuan.city_wall_report()
LANGUAGE plpgsql
AS
$$
DECLARE
    nowdate date := NOW();
    endtmp date := NOW();
    adcode_where varchar(100);
    customer_where varchar(100);
    customer_group_field varchar(100);
    factory_group_field varchar(100);
    factory_where varchar(100);
    sql_stmt text;
BEGIN
    nowdate := date_sub(CURRENT_DATE, interval '1 day');
    endtmp := CURRENT_DATE;
    
    if (region_type = 'area') then
        adcode_where := 'right(ad.adcode, 4) != ''0000'' and right(ad.adcode, 2) != ''00''';
        customer_where := 'up.company_region';
        customer_group_field := 'company_province, company_city, company_region';
        factory_group_field := 'cf.province, cf.city, cf.area';
        factory_where := 'cf.area';
    elsif (region_type = 'city') then
        adcode_where := 'right(ad.adcode, 4) != ''0000'' and right(ad.adcode, 2) = ''00''';
        customer_where := 'up.company_city';
        customer_group_field := 'company_province, company_city';
        factory_group_field := 'cf.province, cf.city';
        factory_where := 'cf.city';
    else
        adcode_where := 'right(ad.adcode, 4) = ''0000''';
        customer_where := 'up.company_province';
        customer_group_field := 'company_province';
        factory_group_field := 'cf.province';
        factory_where := 'cf.province';
    end if;

    <<insert_loop>>
    WHILE nowdate < endtmp LOOP
        sql_stmt := 'INSERT INTO uct_day_wall_report(adcode, weight, availability, rubbish, rdf, carbon, box, customer_num, report_date) ' ||
                    'SELECT ad.adcode, COALESCE(weight, 0) AS weight, COALESCE(availability, 0) AS availability, COALESCE(rubbish, 0) AS rubbish, ' ||
                    'COALESCE(rdf, 0) AS rdf, COALESCE(carbon, 0) AS carbon, COALESCE(box, 0) AS box, COALESCE(customer.customer_num, 0) AS customer_num, ' ||
                    'nowdate AS report_date FROM uct_adcode ad LEFT JOIN (SELECT ad.adcode, ROUND(SUM(FQty), 2) AS weight, ' ||
                    'ROUND(SUM(CASE WHEN c.name = ''低值废弃物'' THEN FQty ELSE 0 END) / SUM(FQty), 2) AS availability, ' ||
                    'ROUND(SUM(CASE WHEN c.name = ''低值废弃物'' THEN FQty ELSE 0 END), 2) AS rubbish, ' ||
                    'ROUND(SUM(CASE WHEN c.name = ''低值废弃物'' THEN FQty ELSE 0 END) / SUM(FQty) * 4.2, 2) AS rdf, ' ||
                    'ROUND(SUM(FQty * c2.carbon_parm), 2) AS carbon, box.box FROM Trans_main_table mt ' ||
                    'JOIN Trans_main_table mt2 ON mt.FInterId = mt2.FInterId AND mt2.FTranType = ''PUR'' AND ' ||
                    'date_format(mt2.FDate, ''YYYY-MM-DD'') > ''2018-09-30'' AND date_format(mt2.FDate, ''YYYY-MM-DD'') = ' ||
                    'DATE_FORMAT(nowdate, ''YYYY-MM-DD'') JOIN uct_waste_purchase p ON mt.FBillNo = p.order_id ' ||
                    'JOIN uct_waste_customer_factory cf ON cf.id = p.factory_id JOIN uct_adcode ad ON ad.name = ' || factory_where ||
                    'JOIN Trans_assist_table at ON mt.FInterID = at.FinterID AND mt.FTranType = at.FTranType ' ||
                    'JOIN uct_waste_cate c ON c.id = at.FItemID JOIN uct_waste_cate c2 ON c.parent_id = c2.id ' ||
                    'LEFT JOIN (SELECT ad.adcode, SUM(abs(FUseCount)) AS box FROM Trans_main_table mt JOIN uct_waste_purchase p ON mt.FInterID = p.id ' ||
                    'JOIN uct_waste_customer_factory cf ON cf.id = p.factory_id JOIN uct_adcode ad ON ad.name = ' || factory_where ||
                    'JOIN Trans_materiel_table materiel ON materiel.FInterID = mt.FInterID JOIN uct_materiel materiel2 ON materiel.FMaterielID = materiel2.id ' ||
                    'AND materiel.FTranType IN (''PUR'', ''SOR'') AND materiel2.name = ''分类箱'' WHERE date_format(mt.FDate, ''YYYY-MM-DD'') > ''2018-09-30'' ' ||
                    'AND date_format(mt.FDate, ''YYYY-MM-DD'') = DATE_FORMAT(nowdate, ''YYYY-MM-DD'') AND mt.FTranType = ''PUR'' AND mt.FSaleStyle IN (''0'', ''1'') ' ||
                    'AND mt.FCorrent = ''1'' AND mt.FCancellation = ''1'' AND mt.FRelateBrID != 7 GROUP BY ' || factory_group_field ||
                    ') box ON box.adcode = ad.adcode WHERE mt.FTranType IN (''SOR'', ''SEL'') AND mt.FSaleStyle IN (''0'', ''1'') ' ||
                    'AND mt.FCorrent = ''1'' AND mt.FCancellation = ''1'' AND mt.FRelateBrID != 7 GROUP BY ' || factory_group_field ||
                    ' ORDER BY cf.area) data ON report.adcode = data.adcode ' ||
                    'LEFT JOIN (SELECT ad.adcode, COUNT(*) AS customer_num FROM uct_up up JOIN uct_adcode ad ON ' || customer_where ||
                    ' = ad.name AND first_business_time = nowdate GROUP BY ' || customer_group_field || ') customer ' ||
                    'ON customer.adcode = ad.adcode WHERE ' || adcode_where || ';';
        EXECUTE sql_stmt;
        nowdate := nowdate + interval '1 day';
    END LOOP insert_loop;
END;
$$;




CREATE OR REPLACE PROCEDURE uctoo_lvhuan.cursor_test()
LANGUAGE plpgsql
AS
$$
DECLARE
    done BOOLEAN DEFAULT FALSE;
    pid INT;
    cur1 CURSOR FOR SELECT id FROM uct_admin WHERE id = 2;
    cur2 CURSOR FOR SELECT id FROM uct_admin WHERE id = 3;
BEGIN
    BEGIN
        OPEN cur1;
        FETCH cur1 INTO pid;
        WHILE NOT done LOOP
            IF FOUND THEN
                -- Do something with pid, if needed
                RAISE NOTICE 'cur1: %', pid;
            END IF;
            done := TRUE;
        END LOOP;
        CLOSE cur1;
    EXCEPTION
        WHEN others THEN
            CLOSE cur1;
            RAISE;
    END;

    done := FALSE;

    BEGIN
        OPEN cur2;
        FETCH cur2 INTO pid;
        WHILE NOT done LOOP
            IF FOUND THEN
                -- Do something with pid, if needed
                RAISE NOTICE 'cur2: %', pid;
            END IF;
            done := TRUE;
        END LOOP;
        CLOSE cur2;
    EXCEPTION
        WHEN others THEN
            CLOSE cur2;
            RAISE;
    END;
END;
$$;




CREATE OR REPLACE PROCEDURE uctoo_lvhuan.edit_materiel_num(
    INOUT o_rv INTEGER,
    INOUT o_err VARCHAR(200)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_FInterID INT;
    v_order_id VARCHAR(20);
    v_number INT;
    v_meta_id INT;
    v_meta_price FLOAT;
    v_meta_amount FLOAT;
    v_money_all INT;
    errno INT;
    s INT := 0;
    
    report CURSOR FOR SELECT FInterID, order_id, meta_id, number, meta_price, meta_amount FROM uct_apply_for_material_temp WHERE state = 2;
BEGIN
    OPEN report;
    LOOP
        FETCH report INTO v_FInterID, v_order_id, v_meta_id, v_number, v_meta_price, v_meta_amount;
        EXIT WHEN s = 1;
        
        BEGIN
            -- Start the transaction
            START TRANSACTION;
            
            errno := 0;
            
            INSERT INTO Trans_materiel_table
                    (FInterID,
                    FTranType,
                    FEntryID,
                    FMaterielID,
                    FUseCount,
                    FPrice,
                    FMeterielAmount,
                    FMeterieltime,
                    red_ink_time,
                    is_hedge,
                    revise_state)
             VALUES (v_FInterID,
                    'PUR',
                    0,
                    v_meta_id,
                    v_number,
                    v_meta_price,
                    v_meta_amount,
                    EXTRACT(EPOCH FROM NOW())::INT,
                    NOW(),
                    0,
                    2);
            errno := 1;

            SELECT SUM(FMeterielAmount) INTO v_money_all 
              FROM Trans_materiel_table 
             WHERE FInterID = v_FInterID 
               AND FTranType IN ('SOR','PUR');

            UPDATE Trans_main_table SET
                TalSecond = v_money_all,
                is_hedge = 1,
                red_ink_time = NOW()
             WHERE FInterID = v_FInterID 
               AND FTranType = 'SOR'
               AND FSaleStyle <> 1;
            errno := 2;

            UPDATE uct_apply_for_material_temp SET
                state = 1
             WHERE FInterID = v_FInterID;
            errno := 3;

            COMMIT;

            IF errno = 3 THEN
                o_rv := 200;
                o_err := '处理成功.';
            END IF;
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
                o_rv := 500;
                o_err := '处理失败.';
        END;
        
        FETCH report INTO v_FInterID, v_order_id, v_meta_id, v_number, v_meta_price, v_meta_amount;
    END LOOP;
    
    CLOSE report;
END;
$$;



CREATE OR REPLACE PROCEDURE uctoo_lvhuan.insertManyDate(IN beginDate DATE, IN endDate DATE, IN region_type VARCHAR(20))
LANGUAGE plpgsql
AS $$
DECLARE
    nowdate DATE := beginDate;
    endtmp DATE := endDate;
    adcode_where VARCHAR(100);
    customer_where VARCHAR(100);
    customer_group_field VARCHAR(100);
    factory_group_field VARCHAR(100);
    factory_where VARCHAR(100);
    v_sql TEXT;
BEGIN
    IF region_type = 'area' THEN
        adcode_where := 'right(ad.adcode,4) != ''0000'' and right(ad.adcode,2) != ''00''';
        customer_where := 'up.company_region';
        customer_group_field := 'company_province,company_city,company_region';
        factory_group_field := 'cf.province,cf.city,cf.area';
        factory_where := 'cf.area';
    ELSIF region_type = 'city' THEN
        adcode_where := 'right(ad.adcode,4) != ''0000'' and right(ad.adcode,2) = ''00''';
        customer_where := 'up.company_city';
        customer_group_field := 'company_province,company_city';
        factory_group_field := 'cf.province,cf.city';
        factory_where := 'cf.city';
    ELSE
        adcode_where := 'right(ad.adcode,4) = ''0000''';
        customer_where := 'up.company_province';
        customer_group_field := 'company_province';
        factory_group_field := 'cf.province';
        factory_where := 'cf.province';
    END IF;

    WHILE nowdate < endtmp LOOP
        v_sql := 'INSERT INTO uct_day_wall_report(adcode,weight,availability,rubbish,rdf,carbon,box,customer_num,report_date) '
                 || 'SELECT ad.adcode, COALESCE(weight, 0), COALESCE(availability, 0), COALESCE(rubbish, 0), COALESCE(rdf, 0), '
                 || 'COALESCE(carbon, 0), COALESCE(box, 0), COALESCE(customer.customer_num, 0), ''' || nowdate || ''' '
                 || 'AS report_date FROM uct_adcode ad '
                 || 'LEFT JOIN ('
                 || 'SELECT ad.adcode, round(sum(FQty), 2) as weight, round(sum(CASE WHEN c.name = ''低值废弃物'' THEN FQty ELSE 0 END) / sum(FQty), 2) as availability, '
                 || 'round(sum(CASE WHEN c.name = ''低值废弃物'' THEN FQty ELSE 0 END), 2) as rubbish, round(sum(CASE WHEN c.name = ''低值废弃物'' THEN FQty ELSE 0 END) / sum(FQty) * 4.2, 2) as rdf, '
                 || 'round(sum(FQty * c2.carbon_parm), 2) as carbon, box.box '
                 || 'FROM Trans_main_table mt '
                 || 'JOIN Trans_main_table mt2 ON mt.FInterId = mt2.FInterId AND mt2.FTranType = ''PUR'' AND date_trunc(''day'', mt2.FDate) > ''2018-09-30'' AND date_trunc(''day'', mt2.FDate) = date_trunc(''day'', ''' || nowdate || ''') '
                 || 'JOIN uct_waste_purchase p ON mt.FBillNo = p.order_id '
                 || 'JOIN uct_waste_customer_factory cf ON cf.id = p.factory_id '
                 || 'JOIN uct_adcode ad ON ad.name = ' || factory_where || ' '
                 || 'JOIN Trans_assist_table at ON mt.FInterID = at.FinterID AND mt.FTranType = at.FTranType '
                 || 'JOIN uct_waste_cate c ON c.id = at.FItemID '
                 || 'JOIN uct_waste_cate c2 ON c.parent_id = c2.id '
                 || 'LEFT JOIN ('
                 || 'SELECT ad.adcode, sum(abs(FUseCount)) as box '
                 || 'FROM Trans_main_table mt '
                 || 'JOIN uct_waste_purchase p ON mt.FInterID = p.id '
                 || 'JOIN uct_waste_customer_factory cf ON cf.id = p.factory_id '
                 || 'JOIN uct_adcode ad ON ad.name = ' || factory_where || ' '
                 || 'JOIN Trans_materiel_table materiel ON materiel.FInterID = mt.FInterID '
                 || 'JOIN uct_materiel materiel2 ON materiel.FMaterielID = materiel2.id AND materiel.FTranType IN (''PUR'',''SOR'') AND materiel2.name = ''分类箱'' '
                 || 'WHERE date_trunc(''day'', mt.FDate) > ''2018-09-30'' AND date_trunc(''day'', mt.FDate) = date_trunc(''day'', ''' || nowdate || ''') '
                 || 'AND mt.FTranType = ''PUR'' AND mt.FSaleStyle IN (''0'',''1'') '
                 || 'AND mt.FCorrent = ''1'' AND mt.FCancellation = ''1'' AND mt.FRelateBrID != 7 '
                 || 'GROUP BY ' || factory_group_field || ' ) box  on box.adcode = ad.adcode '
                 || 'WHERE mt.FTranType IN (''SOR'',''SEL'') AND mt.FSaleStyle IN (''0'',''1'') '
                 || 'AND mt.FCorrent = ''1'' AND mt.FCancellation = ''1'' AND mt.FRelateBrID != 7 '
                 || 'GROUP BY ' || factory_group_field || ' ORDER BY cf.area) data ON ad.adcode = data.adcode '
                 || 'LEFT JOIN ('
                 || 'SELECT ad.adcode , count(*) as customer_num '
                 || 'FROM uct_up up JOIN uct_adcode ad ON ' || customer_where || ' = ad.name AND first_business_time = date_trunc(''day'', ''' || nowdate || ''') '
                 || 'GROUP BY ' || customer_group_field || ') customer ON customer.adcode = ad.adcode '
                 || 'WHERE ' || adcode_where || ';';

        EXECUTE v_sql;

        nowdate := nowdate + INTERVAL '1 DAY';
    END LOOP;
END;
$$;



CREATE OR REPLACE PROCEDURE uctoo_lvhuan.insertOneLevelAccumulate(IN region_type VARCHAR(50))
LANGUAGE plpgsql
AS $$
DECLARE 
    group_field VARCHAR(50);
    region_where VARCHAR(50);
    v_sql TEXT;
BEGIN
    IF region_type = 'area' THEN
        group_field := 'cf.province,cf.city,cf.area';
        region_where := 'ad.name = cf.area';
    ELSIF region_type = 'city' THEN
        group_field := 'cf.province,cf.city';
        region_where := 'ad.name = cf.city';
    ELSE
        group_field := 'cf.province';
        region_where := 'ad.name = cf.province';
    END IF;

    v_sql := 'REPLACE INTO uct_one_level_accumulate_wall_report(adcode, name, weight, carbon) '
             || 'SELECT ad.adcode, c3.name, round(sum(FQty), 2) as weight, round(sum(FQty * c2.carbon_parm), 2) as carbon '
             || 'FROM Trans_main_table mt '
             || 'JOIN Trans_main_table mt2 ON mt.FInterId = mt2.FInterId AND mt2.FTranType = ''PUR'' AND date_trunc(''day'', mt2.FDate) > ''2018-09-30'' '
             || 'JOIN uct_waste_purchase p ON mt.FBillNo = p.order_id '
             || 'JOIN uct_waste_customer_factory cf ON cf.id = p.factory_id '
             || 'JOIN uct_adcode ad ON ' || region_where || ' '
             || 'JOIN Trans_assist_table at ON mt.FInterID = at.FinterID AND mt.FTranType = at.FTranType '
             || 'JOIN uct_waste_cate c ON c.id = at.FItemID '
             || 'JOIN uct_waste_cate c2 ON c.parent_id = c2.id '
             || 'JOIN uct_waste_cate c3 ON c2.parent_id = c3.id '
             || 'WHERE mt.FTranType IN (''SOR'',''SEL'') AND mt.FSaleStyle IN (''0'',''1'') '
             || 'AND mt.FCorrent = ''1'' AND mt.FCancellation = ''1'' AND mt.FRelateBrID != 7 '
             || 'GROUP BY ' || group_field || ', c3.name '
             || 'ORDER BY weight;';

    EXECUTE v_sql;
END;
$$;


CREATE OR REPLACE PROCEDURE uctoo_lvhuan.insertOneLevelManyDate(IN beginDate DATE, IN endDate DATE, IN region_type VARCHAR(20))
LANGUAGE plpgsql
AS $$
DECLARE 
    nowdate DATE := NOW();
    endtmp DATE := NOW();
    group_field VARCHAR(50);
    region_where VARCHAR(50);
    v_sql TEXT;
BEGIN
    IF region_type = 'area' THEN
        group_field := 'cf.province,cf.city,cf.area';
        region_where := 'ad.name = cf.area';
    ELSIF region_type = 'city' THEN
        group_field := 'cf.province,cf.city';
        region_where := 'ad.name = cf.city';
    ELSE
        group_field := 'cf.province';
        region_where := 'ad.name = cf.province';
    END IF;

    nowdate := beginDate;
    endtmp := endDate;
    
    WHILE nowdate < endtmp LOOP

        v_sql := 'INSERT INTO uct_one_level_day_wall_report(adcode, name, weight, carbon, report_date) '
                 || 'SELECT ad.adcode, c3.name, round(sum(FQty), 2) as weight, round(sum(FQty * c2.carbon_parm), 2) as carbon, ''' || nowdate || ''' as report_date '
                 || 'FROM Trans_main_table mt '
                 || 'JOIN Trans_main_table mt2 ON mt.FInterId = mt2.FInterId AND mt2.FTranType = ''PUR'' AND mt2.FDate > ''2018-09-30'' AND mt2.FDate = ''' || nowdate || ''' '
                 || 'JOIN uct_waste_purchase p ON mt.FBillNo = p.order_id '
                 || 'JOIN uct_waste_customer_factory cf ON cf.id = p.factory_id '
                 || 'JOIN uct_adcode ad ON ' || region_where || ' '
                 || 'JOIN Trans_assist_table at ON mt.FInterID = at.FinterID AND mt.FTranType = at.FTranType '
                 || 'JOIN uct_waste_cate c ON c.id = at.FItemID '
                 || 'JOIN uct_waste_cate c2 ON c.parent_id = c2.id '
                 || 'JOIN uct_waste_cate c3 ON c2.parent_id = c3.id '
                 || 'WHERE mt.FTranType IN (''SOR'',''SEL'') AND mt.FSaleStyle IN (''0'',''1'') '
                 || 'AND mt.FCorrent = ''1'' AND mt.FCancellation = ''1'' AND mt.FRelateBrID != 7 '
                 || 'GROUP BY ' || group_field || ', c3.name '
                 || 'ORDER BY weight;';

        EXECUTE v_sql;

        nowdate := nowdate + INTERVAL '1 DAY';
    END LOOP;
END;
$$;








CREATE OR REPLACE PROCEDURE uctoo_lvhuan.insertReportAccumulate(region_type VARCHAR(50))
LANGUAGE plpgsql
AS $$
DECLARE 
    group_field VARCHAR(50);
    region_where VARCHAR(50);
    adcode_where VARCHAR(100);
    customer_where VARCHAR(100);
    customer_group_field VARCHAR(100);
    factory_group_field VARCHAR(100);
    factory_where VARCHAR(100);
BEGIN
    IF region_type = 'area' THEN
        adcode_where := 'right(ad.adcode, 4) != ''0000'' and right(ad.adcode, 2) != ''00''';
        customer_where := 'up.company_region';
        customer_group_field := 'company_province, company_city, company_region';
        factory_group_field := 'cf.province, cf.city, cf.area';
        factory_where := 'cf.area';
    ELSIF region_type = 'city' THEN
        adcode_where := 'right(ad.adcode, 4) != ''0000'' and right(ad.adcode, 2) = ''00''';
        customer_where := 'up.company_city';
        customer_group_field := 'company_province, company_city';
        factory_group_field := 'cf.province, cf.city';
        factory_where := 'cf.city';
    ELSE
        adcode_where := 'right(ad.adcode, 4) = ''0000''';
        customer_where := 'up.company_province';
        customer_group_field := 'company_province';
        factory_group_field := 'cf.province';
        factory_where := 'cf.province';
    END IF;

    EXECUTE '
        INSERT INTO uct_accumulate_wall_report(adcode, weight, availability, rubbish, rdf, carbon, box, customer_num)
        SELECT ad.adcode,
               COALESCE(weight, 0) AS weight,
               COALESCE(availability, 0) AS availability,
               COALESCE(rubbish, 0) AS rubbish,
               COALESCE(rdf, 0) AS rdf,
               COALESCE(carbon, 0) AS carbon,
               COALESCE(box, 0) AS box,
               COALESCE(customer.customer_num, 0) AS customer_num
        FROM uct_adcode ad
        LEFT JOIN (
            SELECT ad.adcode,
                   round(sum(FQty), 2) AS weight,
                   round(sum(CASE WHEN c.name = ''低值废弃物'' THEN FQty ELSE 0 END) / sum(FQty), 2) AS availability,
                   round(sum(CASE WHEN c.name = ''低值废弃物'' THEN FQty ELSE 0 END), 2) AS rubbish,
                   round(sum(CASE WHEN c.name = ''低值废弃物'' THEN FQty ELSE 0 END) / sum(FQty) * 4.2, 2) AS rdf,
                   round(sum(FQty * c2.carbon_parm), 2) AS carbon,
                   box.box
            FROM Trans_main_table mt
            JOIN Trans_main_table mt2 ON mt.FInterId = mt2.FInterId AND mt2.FTranType = ''PUR'' AND date_trunc(''day'', mt2.FDate) > ''2018-09-30''
            JOIN uct_waste_purchase p ON mt.FBillNo = p.order_id
            JOIN uct_waste_customer_factory cf ON cf.id = p.factory_id
            JOIN uct_adcode ad ON ad.name = ' || factory_where ||
            'JOIN Trans_assist_table at ON mt.FInterID = at.FinterID AND mt.FTranType = at.FTranType
            JOIN uct_waste_cate c ON c.id = at.FItemID
            JOIN uct_waste_cate c2 ON c.parent_id = c2.id
            LEFT JOIN (
                SELECT ad.adcode, sum(abs(FUseCount)) AS box
                FROM Trans_main_table mt
                JOIN uct_waste_purchase p ON mt.FInterID = p.id
                JOIN uct_waste_customer_factory cf ON cf.id = p.factory_id
                JOIN uct_adcode ad ON ad.name = ' || factory_where ||
                'JOIN Trans_materiel_table materiel ON materiel.FInterID = mt.FInterID
                JOIN uct_materiel materiel2 ON materiel.FMaterielID = materiel2.id AND materiel.FTranType IN (''PUR'',''SOR'') AND materiel2.name = ''分类箱''
                WHERE date_trunc(''day'', mt.FDate) > ''2018-09-30'' AND mt.FTranType = ''PUR'' AND mt.FSaleStyle IN (''0'',''1'')
                AND mt.FCorrent = ''1'' AND mt.FCancellation = ''1'' AND mt.FRelateBrID != 7
                GROUP BY ' || factory_group_field || ' ORDER BY cf.area
            ) box ON box.adcode = ad.adcode
            WHERE mt.FTranType IN (''SOR'',''SEL'') AND mt.FSaleStyle IN (''0'',''1'') AND mt.FCorrent = ''1''
            AND mt.FCancellation = ''1'' AND mt.FRelateBrID != 7
            GROUP BY ' || factory_group_field || ' ORDER BY cf.area
        ) data ON ad.adcode = data.adcode
        LEFT JOIN (
            SELECT ad.adcode, count(*) AS customer_num
            FROM uct_up up
            JOIN uct_adcode ad ON ' || customer_where || ' = ad.name
            GROUP BY ' || customer_group_field ||
            ') customer ON customer.adcode = ad.adcode
        WHERE ' || adcode_where;
END;
$$;



CREATE OR REPLACE PROCEDURE uctoo_lvhuan.insertStockHistory()
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO Accoding_stock_history 
    SELECT 
        uct_waste_warehouse.branch_id AS FRelateBrID,
        'LH' || uct_waste_warehouse.id AS FStockID,
        Trans_assist_table.FItemID AS FItemID,
        ROUND(COALESCE(SUM(Trans_assist_table.FQty * CASE WHEN Trans_main_table.FTranType = 'SOR' THEN 1 ELSE 0 END), 0), 1) AS FDCQty,
        ROUND(COALESCE(SUM(Trans_assist_table.FQty * CASE WHEN Trans_main_table.FTranType = 'SEL' THEN 1 ELSE 0 END), 0), 1) AS FSCQty,
        '0' AS FdifQty,
        (date_trunc('day', COALESCE(Trans_assist_table.red_ink_time, Trans_assist_table.FDCTime)) + INTERVAL '1 day' - INTERVAL '1 second') AS FDCTime
    FROM 
        Trans_assist_table
    JOIN 
        Trans_main_table ON Trans_assist_table.FinterID = Trans_main_table.FInterID AND Trans_assist_table.FTranType = Trans_main_table.FTranType
    JOIN 
        uct_waste_cate ON uct_waste_cate.id = Trans_assist_table.FItemID
    JOIN 
        uct_waste_warehouse ON uct_waste_cate.branch_id = uct_waste_warehouse.branch_id AND uct_waste_warehouse.parent_id = 0 AND uct_waste_warehouse.state = 1
    WHERE 
        Trans_main_table.FSaleStyle <> 1
        AND Trans_main_table.FCancellation = 1
        AND (date_trunc('day', Trans_assist_table.FDCTime) = (CURRENT_DATE - INTERVAL '1 day') AND Trans_assist_table.red_ink_time IS NULL)
           OR (date_trunc('day', Trans_assist_table.red_ink_time) = (CURRENT_DATE - INTERVAL '1 day'))
    GROUP BY 
        uct_waste_warehouse.id,
        Trans_assist_table.FItemID,
        date_trunc('day', COALESCE(Trans_assist_table.red_ink_time, Trans_assist_table.FDCTime))
    HAVING 
        uct_waste_warehouse.id IS NOT NULL;

    INSERT INTO Accoding_stock_history 
    SELECT 
        uct_cate_account.branch_id AS FRelateBrID,
        'LH' || uct_cate_account.warehouse_id AS FStockID,
        uct_cate_account.cate_id AS FItemID,
        '0' AS FDCQty,
        '0' AS FSCQty,
        uct_cate_account.before_account_num - uct_cate_account.account_num AS FdifQty,
        (date_trunc('day', to_timestamp(uct_cate_account.createtime)) + INTERVAL '1 day' - INTERVAL '1 second') AS FDCTime
    FROM 
        uct_cate_account
    WHERE 
        date_trunc('day', to_timestamp(uct_cate_account.createtime)) = (CURRENT_DATE - INTERVAL '1 day');
END;
$$;







CREATE OR REPLACE PROCEDURE uctoo_lvhuan.lh_dw_month_report_del(INOUT p_day varchar(50))
LANGUAGE plpgsql AS
$$
DECLARE
    errno int;
    v_new_day varchar(50);
BEGIN
    BEGIN
        -- Error handling
        BEGIN
            SELECT TO_CHAR(p_day::date + INTERVAL '0 month', 'YYYY-MM') INTO v_new_day;
        EXCEPTION
            WHEN others THEN
                GET STACKED DIAGNOSTICS errno = PG_EXCEPTION_CONTEXT;
                RAISE EXCEPTION '月报表数据删除失败. 错误码: %', errno;
        END;

        errno := 100;

        IF v_new_day IS NOT NULL THEN
            errno := 101;
        END IF;

        DELETE FROM lh_dw.data_statistics_results
        WHERE time_dims = 'M' AND time_val = v_new_day;

        errno := 102;

        IF errno = 102 THEN
            RAISE NOTICE '月报表数据删除成功.';
        END IF;
    EXCEPTION
        WHEN others THEN
            RAISE EXCEPTION '发生异常: %', SQLERRM;
    END;
END;
$$;




CREATE OR REPLACE PROCEDURE uctoo_lvhuan.lh_dw_visual_check_to_execute()
LANGUAGE plpgsql AS
$$
DECLARE
    v_id int;
    v_pre_tasks varchar(100);
    v_exec_way varchar(20);
    v_exec_alg varchar(10000);
    v_err_logs varchar(200);
    o_rv int;
    o_err varchar(100);
    v_exec_state int;
    sqlUp varchar(800);
    sqlStr varchar(800);
    v_sql varchar(800);
    v_sql_str varchar(800);
    statu varchar(20);
    v_filed varchar(20);
    v_status int;
    v_res_exec_state int;
    v_res_err_logs varchar(200);
    errno int;
    v_exec_code varchar(300);
    v_count_num int;
    v_log_type varchar(30);
    v_res_exec_type varchar(30);
    s int := 0;
    
    report CURSOR FOR SELECT id, pre_tasks, exec_way, exec_alg, err_logs, exec_state, code
                      FROM lh_dw.data_statistics_execution
                      WHERE EXTRACT(EPOCH FROM exec_time) <= EXTRACT(EPOCH FROM now()) 
                      AND exec_way = 'sql' 
                      AND code LIKE 'visualization-large-data%' 
                      AND exec_state IN (0, 2);
BEGIN
    OPEN report;

    LOOP
        FETCH report INTO v_id, v_pre_tasks, v_exec_way, v_exec_alg, v_err_logs, v_exec_state, v_exec_code;
        EXIT WHEN NOT FOUND;

        v_exec_alg := TRIM(v_exec_alg);
        v_id := TRIM(v_id);

        SELECT COUNT(*) INTO v_count_num 
        FROM lh_dw.data_statistics_execution_log 
        WHERE exec_id = v_id;
        
        IF v_count_num > 0 THEN
            SELECT IFNULL(exec_type, 'waiting') INTO v_log_type 
            FROM lh_dw.data_statistics_execution_log 
            WHERE exec_id = v_id 
            ORDER BY create_at DESC 
            LIMIT 1;
        END IF;

        IF v_count_num = 0 OR v_log_type = 'failed' THEN
            INSERT INTO lh_dw.data_statistics_execution_log (exec_id, exec_code, exec_type)
            VALUES (v_id, v_exec_code, 'waiting');
        END IF;

        IF v_count_num = 0 OR v_log_type = 'waiting' OR v_log_type = 'failed' THEN
            IF v_pre_tasks = '' OR v_pre_tasks = ' ' OR v_pre_tasks IS NULL THEN
                UPDATE lh_dw.data_statistics_execution_log  
                SET exec_type = 'operation' 
                WHERE exec_id = v_id AND finish_at IS NULL;
                
                CALL lh_dw_table_data_execution(v_id, v_exec_alg, o_rv, o_err);
                
                IF o_rv = 200 THEN
                    v_res_exec_state := 1;
                    v_res_err_logs := '';
                    v_res_exec_type := 'finish';
                ELSIF o_rv = 400 THEN
                    v_res_exec_state := 2;
                    v_res_err_logs := o_err;
                    v_res_exec_type := 'failed';
                END IF;
                
                UPDATE lh_dw.data_statistics_execution  
                SET exec_state = v_res_exec_state, err_logs = v_res_err_logs 
                WHERE id = v_id;
                
                UPDATE lh_dw.data_statistics_execution_log  
                SET exec_type = v_res_exec_type, finish_at = now() 
                WHERE exec_id = v_id AND finish_at IS NULL;
            ELSE
                SELECT EXP(SUM(LN(CASE WHEN exec_state = 1 THEN 1 ELSE 2 END))) INTO v_status 
                FROM lh_dw.data_statistics_execution 
                WHERE id IN (SELECT unnest(string_to_array(v_pre_tasks, ','))::int);
                
                IF v_status = 1 THEN
                    UPDATE lh_dw.data_statistics_execution_log  
                    SET exec_type = 'operation' 
                    WHERE exec_id = v_id AND finish_at IS NULL;
                    
                    CALL lh_dw_table_data_execution(v_id, v_exec_alg, o_rv, o_err);
                    
                    IF o_rv = 200 THEN
                        v_res_exec_state := 1;
                        v_res_err_logs := '';
                        v_res_exec_type := 'finish';
                    ELSIF o_rv = 400 THEN
                        v_res_exec_state := 2;
                        v_res_err_logs := o_err;
                        v_res_exec_type := 'failed';
                    END IF;
                    
                    UPDATE lh_dw.data_statistics_execution  
                    SET exec_state = v_res_exec_state, err_logs = v_res_err_logs 
                    WHERE id = v_id;
                    
                    UPDATE lh_dw.data_statistics_execution_log  
                    SET exec_type = v_res_exec_type, finish_at = now() 
                    WHERE exec_id = v_id AND finish_at IS NULL;
                END IF;
            END IF;
        END IF;
    END LOOP;

    CLOSE report;
END;
$$;



CREATE OR REPLACE PROCEDURE uctoo_lvhuan.lh_dw_warehouse_day_mysql(INOUT p_day varchar(50), INOUT o_rv integer, INOUT o_err varchar(200))
LANGUAGE plpgsql
AS
$$
DECLARE
    errno integer;
    v_month_begin integer;
    v_month_end integer;
    v_month varchar(20);
    v_last_day varchar(20);
    v_before_day varchar(20);
    v_today_day integer;
    v_new_day varchar(20);
BEGIN
    -- 在PostgreSQL中没有sqlexception，异常处理使用EXCEPTION子句
    BEGIN
        -- 初始化日期相关的变量
        SELECT EXTRACT(EPOCH FROM (DATE_TRUNC('MONTH', NOW()) - INTERVAL '1 MONTH'))::integer,
               EXTRACT(EPOCH FROM (DATE_TRUNC('MONTH', NOW()) + INTERVAL '1 MONTH - 1 second'))::integer,
               TO_CHAR(NOW(), 'YYYY-MM'),
               TO_CHAR(NOW(), 'YYYY-MM-DD'),
               TO_CHAR((DATE_TRUNC('MONTH', NOW()) - INTERVAL '1 MONTH'), 'YYYY-MM-DD'),
               EXTRACT(EPOCH FROM (p_day || ' 12:00:00'))::integer
        INTO v_month_begin, v_month_end, v_month, v_last_day, v_before_day, v_today_day;

        -- 确保日期在有效范围内
        IF v_today_day > v_month_end THEN
            o_rv := 400;
            o_err := '不能给定未来的日期';
            RETURN;
        END IF;

        IF v_today_day < v_month_begin THEN
            v_new_day := v_before_day;
        ELSIF v_month_begin < v_today_day AND v_today_day < v_month_end THEN
            v_new_day := v_last_day;
        END IF;

        -- 开始事务
        BEGIN
            -- 业务逻辑部分...

            -- 第一个插入语句
            INSERT INTO lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, 
                                                       group1, group2, txt1, val1, val2, val3, val4, val5)
            SELECT 'D' as time_dims,
                   baseTime.time_val,
                   TO_TIMESTAMP(baseTime.begin_time) as begin_time,
                   TO_TIMESTAMP(baseTime.end_time) as end_time,
                   '分部-仓库' as data_dims,
                   ware.branch_id as data_val,
                   'warehouse-daily-report' as stat_code,
                   'warehouse-weight' as group1,
                   'PUR/SEL' as group2,
                   ware.name as txt1,
                   COALESCE(detail.totalWeight, 0) as val1,
                   COALESCE(detail.totalValue, 0) as val2,
                   COALESCE(detail.totalUnvalue, 0) as val3,
                   COALESCE(selTotal.toatlQty, 0) as val4,
                   COALESCE(selTotal.toatlAmout, 0) as val5
            FROM (SELECT EXTRACT(EPOCH FROM (p_day::date - INTERVAL '1 DAY'))::integer as begin_time,
                         EXTRACT(EPOCH FROM (p_day::date - INTERVAL '1 DAY' + INTERVAL '1 DAY - 1 second'))::integer as end_time,
                         (p_day::date - INTERVAL '1 DAY') as time_val
                 ) as baseTime
            LEFT JOIN uct_waste_warehouse AS ware
                ON ware.parent_id = 0
               AND ware.state = 1
            LEFT JOIN (SELECT house.branch_id,
                              main.FDCStockID,
                              ROUND(SUM(deat.FQty), 3) as totalWeight,
                              ROUND(SUM(CASE WHEN deat.value_type = 'valuable' THEN deat.FQty ELSE 0 END), 3) as totalValue,
                              ROUND(SUM(CASE WHEN deat.value_type = 'unvaluable' THEN deat.FQty ELSE 0 END), 3) as totalUnvalue
                         FROM (SELECT EXTRACT(EPOCH FROM (p_day::date - INTERVAL '1 DAY'))::integer as begin_time,
                                      EXTRACT(EPOCH FROM (p_day::date - INTERVAL '1 DAY' + INTERVAL '1 DAY - 1 second'))::integer as end_time
                               ) as base
                         LEFT JOIN Trans_assist_table AS deat
                             ON UNIX_TIMESTAMP(deat.FDCTime) BETWEEN base.begin_time AND base.end_time
                         LEFT JOIN Trans_main_table AS main
                             ON deat.FinterID = main.FInterID
                            AND deat.FTranType = main.FTranType
                         LEFT JOIN uct_waste_warehouse as house
                             ON SUBSTRING(main.FDCStockID, 3) = house.id
                         WHERE main.FCancellation <> 0
                           AND house.parent_id = 0
                           AND house.state = 1
                           AND main.FTranType = 'SOR'
                         GROUP BY house.branch_id, main.FDCStockID
                     ) as detail
                ON ware.branch_id = detail.branch_id
            LEFT JOIN (SELECT house.branch_id,
                              main.FDCStockID,
                              ROUND(SUM(deat.FQty), 3) as toatlQty,
                              ROUND(SUM(deat.FAmount), 3) as toatlAmout
                         FROM (SELECT EXTRACT(EPOCH FROM (p_day::date - INTERVAL '1 DAY'))::integer as begin_time,
                                      EXTRACT(EPOCH FROM (p_day::date - INTERVAL '1 DAY' + INTERVAL '1 DAY - 1 second'))::integer as end_time
                               ) as base
                         LEFT JOIN Trans_assist_table AS deat
                             ON UNIX_TIMESTAMP(deat.FDCTime) BETWEEN base.begin_time AND base.end_time
                         LEFT JOIN Trans_main_table AS main
                             ON deat.FinterID = main.FInterID
                            AND deat.FTranType = main.FTranType
                         LEFT JOIN uct_waste_warehouse as house
                             ON SUBSTRING(main.FSCStockID, 3) = house.id
                         WHERE main.FCancellation <> 0
                           AND house.parent_id = 0
                           AND house.state = 1
                           AND main.FTranType = 'SEL'
                           AND main.FSaleStyle = 2
                           AND main.FCorrent = 1
                         GROUP BY house.branch_id, main.FDCStockID
                     ) as selTotal
                ON ware.branch_id = selTotal.branch_id;

            -- 其他插入语句...

            -- 成功完成事务，设置返回值和输出参数
            o_rv := 200;
            o_err := '仓库数据生成成功。';
            RETURN;
        EXCEPTION
            WHEN OTHERS THEN
                -- 回滚事务
                ROLLBACK;
                GET STACKED DIAGNOSTICS errno = RETURNED_SQLSTATE;
                o_rv := errno;
                o_err := '仓库数据生成失败。';
                RETURN;
        END;
    END;
END;
$$;



CREATE OR REPLACE PROCEDURE uctoo_lvhuan.lh_dw_warehouse_month_mysql(
    IN p_day VARCHAR(50),
    INOUT o_rv INTEGER,
    INOUT o_err VARCHAR(200)
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_month_begin INTEGER;
    v_month_end INTEGER;
    v_month VARCHAR(20);
    v_last_day VARCHAR(20);
    v_before_day VARCHAR(20);
    v_today_day INTEGER;
    v_new_day VARCHAR(20);
BEGIN
    BEGIN
        SELECT EXTRACT(EPOCH FROM DATE_TRUNC('MONTH', TO_TIMESTAMP(p_day, 'YYYY-MM-DD') - INTERVAL '1 MONTH'))::INTEGER,
               EXTRACT(EPOCH FROM (DATE_TRUNC('MONTH', TO_TIMESTAMP(p_day, 'YYYY-MM-DD') - INTERVAL '1 MONTH') + INTERVAL '1 MONTH - 1 day'))::INTEGER,
               TO_CHAR(DATE_TRUNC('MONTH', TO_TIMESTAMP(p_day, 'YYYY-MM-DD') - INTERVAL '1 MONTH'), 'YYYY-MM'),
               TO_CHAR(TO_TIMESTAMP(p_day, 'YYYY-MM-DD'), 'YYYY-MM-DD'),
               TO_CHAR(DATE_TRUNC('MONTH', TO_TIMESTAMP(p_day, 'YYYY-MM-DD') - INTERVAL '2 MONTH') + INTERVAL '1 MONTH - 1 day', 'YYYY-MM-DD'),
               EXTRACT(EPOCH FROM TO_TIMESTAMP(p_day || ' 12:00:00', 'YYYY-MM-DD HH24:MI:SS'))
        INTO v_month_begin, v_month_end, v_month, v_last_day, v_before_day, v_today_day;

        IF v_today_day > v_month_end THEN
            o_rv := 400;
            o_err := '不能给定未来的日期';
            RETURN;
        END IF;

        IF v_today_day < v_month_begin THEN
            v_new_day := v_before_day;
        END IF;

        IF v_month_begin < v_today_day AND v_today_day < v_month_end THEN
            v_new_day := v_last_day;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        ROLLBACK;
        o_rv := 1000;
        o_err := '仓库月数据生成失败: ' || SQLERRM;
        RETURN;
    END;

    BEGIN
        START TRANSACTION;
        BEGIN
            INSERT INTO lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, txt1, val1, val2, val3, val4, val5) 
            SELECT 'M' as time_dims, baseTime.time_val, TO_TIMESTAMP(baseTime.begin_time), TO_TIMESTAMP(baseTime.end_time),
                   '分部-仓库' as data_dims, ware.branch_id as data_val, 'warehouse-month-report' as stat_code, 'warehouse-weight' as group1, 'PUR/SEL' as group2, ware.name as txt1,
                   COALESCE(detail.totalWeight, 0) as val1, COALESCE(detail.totalValue, 0) as val2,
                   COALESCE(detail.totalUnvalue, 0) as val3, COALESCE(selTotal.toatlQty, 0) as val4,
                   COALESCE(selTotal.toatlAmout, 0) as val5
            FROM (SELECT EXTRACT(EPOCH FROM DATE_TRUNC('MONTH', TO_TIMESTAMP(p_day, 'YYYY-MM-DD') - INTERVAL '1 MONTH'))::INTEGER as begin_time,
                         EXTRACT(EPOCH FROM (DATE_TRUNC('MONTH', TO_TIMESTAMP(p_day, 'YYYY-MM-DD') - INTERVAL '1 MONTH') + INTERVAL '1 MONTH - 1 day'))::INTEGER as end_time,
                         TO_CHAR(DATE_TRUNC('MONTH', TO_TIMESTAMP(p_day, 'YYYY-MM-DD') - INTERVAL '1 MONTH'), 'YYYY-MM') as time_val
                 ) as baseTime
            JOIN uct_waste_warehouse AS ware ON ware.parent_id = 0 AND ware.state = 1
            LEFT JOIN (SELECT house.branch_id, main.FDCStockID,
                              ROUND(SUM(deat.FQty), 3) as totalWeight,
                              ROUND(SUM(CASE WHEN deat.value_type = 'valuable' THEN deat.FQty ELSE 0 END), 3) as totalValue,
                              ROUND(SUM(CASE WHEN deat.value_type = 'unvaluable' THEN deat.FQty ELSE 0 END), 3) as totalUnvalue
                       FROM (SELECT EXTRACT(EPOCH FROM DATE_TRUNC('MONTH', TO_TIMESTAMP(p_day, 'YYYY-MM-DD') - INTERVAL '1 MONTH'))::INTEGER as begin_time,
                                    EXTRACT(EPOCH FROM (DATE_TRUNC('MONTH', TO_TIMESTAMP(p_day, 'YYYY-MM-DD') - INTERVAL '1 MONTH') + INTERVAL '1 MONTH - 1 day'))::INTEGER as end_time
                            ) as base
                       JOIN Trans_assist_table AS deat ON EXTRACT(EPOCH FROM deat.FDCTime) BETWEEN base.begin_time AND base.end_time
                       LEFT JOIN Trans_main_table AS main ON deat.FinterID = main.FInterID AND deat.FTranType = main.FTranType
                       LEFT JOIN uct_waste_warehouse as house ON SUBSTRING(main.FDCStockID, 3) = house.id
                       WHERE main.FCancellation <> 0 AND EXTRACT(EPOCH FROM deat.FDCTime) BETWEEN base.begin_time AND base.end_time 
                             AND house.parent_id = 0 AND house.state = 1 AND main.FTranType = 'SOR'
                       GROUP BY house.branch_id
             ) as detail ON ware.branch_id = detail.branch_id
             LEFT JOIN (SELECT house.branch_id, main.FDCStockID, ROUND(SUM(deat.FQty), 3) as toatlQty, ROUND(SUM(deat.FAmount), 3) as toatlAmout
                        FROM (SELECT EXTRACT(EPOCH FROM DATE_TRUNC('MONTH', TO_TIMESTAMP(p_day, 'YYYY-MM-DD') - INTERVAL '1 MONTH'))::INTEGER as begin_time,
                                     EXTRACT(EPOCH FROM (DATE_TRUNC('MONTH', TO_TIMESTAMP(p_day, 'YYYY-MM-DD') - INTERVAL '1 MONTH') + INTERVAL '1 MONTH - 1 day'))::INTEGER as end_time
                              ) as base
                        JOIN Trans_assist_table AS deat ON EXTRACT(EPOCH FROM deat.FDCTime) BETWEEN base.begin_time AND base.end_time
                        LEFT JOIN Trans_main_table AS main ON deat.FinterID = main.FInterID AND deat.FTranType = main.FTranType
                        LEFT JOIN uct_waste_warehouse as house ON SUBSTRING(main.FSCStockID, 3) = house.id
                        WHERE main.FCancellation <> 0 AND EXTRACT(EPOCH FROM deat.FDCTime) BETWEEN base.begin_time AND base.end_time 
                              AND house.parent_id = 0 AND house.state = 1 AND main.FTranType = 'SEL' AND main.FSaleStyle = 2 AND main.FCorrent = 1
                        GROUP BY house.branch_id
             ) as selTotal ON ware.branch_id = selTotal.branch_id;

             EXCEPTION WHEN OTHERS THEN
                 ROLLBACK;
                 o_rv := 1001;
                 o_err := '仓库月数据生成失败: ' || SQLERRM;
                 RETURN;
         END;

         BEGIN
             INSERT INTO lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, txt1, val1, val2) 
             SELECT 'M' as time_dims, baseTime.time_val, TO_TIMESTAMP(baseTime.begin_time), TO_TIMESTAMP(baseTime.end_time),
                    '分部-仓库' as data_dims, ware.branch_id as data_val, 'warehouse-month-report' as stat_code, 'warehouse-weight' as group1, 'storage' as group2, ware.name as txt1,
                    COALESCE(detail.FQty, 0) as val1, COALESCE(detail.Amount, 0) as val2
             FROM (SELECT EXTRACT(EPOCH FROM DATE_TRUNC('MONTH', TO_TIMESTAMP(p_day, 'YYYY-MM-DD') - INTERVAL '1 MONTH'))::INTEGER as begin_time,
                          EXTRACT(EPOCH FROM (DATE_TRUNC('MONTH', TO_TIMESTAMP(p_day, 'YYYY-MM-DD') - INTERVAL '1 MONTH') + INTERVAL '1 MONTH - 1 day'))::INTEGER as end_time,
                          TO_CHAR(DATE_TRUNC('MONTH', TO_TIMESTAMP(p_day, 'YYYY-MM-DD') - INTERVAL '1 MONTH'), 'YYYY-MM') as time_val
                  ) as baseTime
             JOIN uct_waste_warehouse AS ware ON ware.parent_id = 0 AND ware.state = 1
             LEFT JOIN (SELECT main.FRelateBrID, ROUND(SUM(main.FQty), 3) as FQty, ROUND(SUM(main.FQty*cate.presell_price), 3) as Amount
                        FROM (SELECT stoC.FRelateBrID AS FRelateBrID, stoC.FItemID AS FItemID, 
                                     CASE 
                                     WHEN EXTRACT(EPOCH FROM stodif.FdifTime) > EXTRACT(EPOCH FROM v_new_day::timestamp) THEN stodif.FdifQty - COALESCE(SUM(stoiod.FDCQty), 0) + COALESCE(SUM(stoiod.FSCQty), 0) + COALESCE(SUM(stoiod.FdifQty), 0)
                                     ELSE stodif.FdifQty + COALESCE(SUM(stoiod.FDCQty), 0) - COALESCE(SUM(stoiod.FSCQty), 0)
                                     END AS FQty
                               FROM Accoding_stock_cate stoC
                               LEFT JOIN Accoding_stock_dif stodif ON stoC.FStockID = stodif.FStockID AND stoC.FItemID = stodif.FItemID
                               LEFT JOIN Accoding_stock_iod stoiod ON (convert(stoC.FStockID USING utf8) = stoiod.FStockID) AND (stoC.FItemID = stoiod.FItemID)
                                       AND (EXTRACT(EPOCH FROM stodif.FdifTime) > EXTRACT(EPOCH FROM v_new_day::timestamp) AND EXTRACT(EPOCH FROM stoiod.FDCTime) BETWEEN EXTRACT(EPOCH FROM v_new_day::timestamp) + 1 AND EXTRACT(EPOCH FROM stodif.FdifTime))
                                       OR (EXTRACT(EPOCH FROM stodif.FdifTime) <= EXTRACT(EPOCH FROM v_new_day::timestamp) AND EXTRACT(EPOCH FROM stoiod.FDCTime) BETWEEN EXTRACT(EPOCH FROM stodif.FdifTime) + 1 AND EXTRACT(EPOCH FROM v_new_day::timestamp))
                               GROUP BY stoC.FStockID, stoC.FItemID, stodif.FdifTime
                        ) AS main
                        JOIN uct_waste_cate cate ON cate.id = main.FItemID
                        GROUP BY main.FRelateBrID
             ) as detail ON ware.branch_id = detail.FRelateBrID;

             EXCEPTION WHEN OTHERS THEN
                 ROLLBACK;
                 o_rv := 1002;
                 o_err := '仓库月数据生成失败: ' || SQLERRM;
                 RETURN;
         END;

         BEGIN
             INSERT INTO lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, txt1, val1) 
             SELECT 'M' as time_dims, baseTime.time_val, TO_TIMESTAMP(baseTime.begin_time), TO_TIMESTAMP(baseTime.end_time),
                    '分部-仓库' as data_dims, ware.branch_id as data_val, 'warehouse-month-report' as stat_code, 'warehouse-weight' as group1, 'vehicle' as group2, ware.name as txt1,
                    COALESCE(detail.totalNum, 0) as val1
             FROM (SELECT EXTRACT(EPOCH FROM DATE_TRUNC('MONTH', TO_TIMESTAMP(p_day, 'YYYY-MM-DD') - INTERVAL '1 MONTH'))::INTEGER as begin_time,
                          EXTRACT(EPOCH FROM (DATE_TRUNC('MONTH', TO_TIMESTAMP(p_day, 'YYYY-MM-DD') - INTERVAL '1 MONTH') + INTERVAL '1 MONTH - 1 day'))::INTEGER as end_time,
                          TO_CHAR(DATE_TRUNC('MONTH', TO_TIMESTAMP(p_day, 'YYYY-MM-DD') - INTERVAL '1 MONTH'), 'YYYY-MM') as time_val
                  ) as baseTime
             JOIN uct_waste_warehouse AS ware ON ware.parent_id = 0 AND ware.state = 1
             LEFT JOIN (SELECT ware.branch_id, ROUND(SUM(main.FTrainNum), 1) as totalNum
                        FROM (SELECT EXTRACT(EPOCH FROM DATE_TRUNC('MONTH', TO_TIMESTAMP(p_day, 'YYYY-MM-DD') - INTERVAL '1 MONTH'))::INTEGER as begin_time,
                                     EXTRACT(EPOCH FROM (DATE_TRUNC('MONTH', TO_TIMESTAMP(p_day, 'YYYY-MM-DD') - INTERVAL '1 MONTH') + INTERVAL '1 MONTH - 1 day'))::INTEGER as end_time
                              ) as base
                        JOIN Trans_main_table AS main ON EXTRACT(EPOCH FROM logt.FTranType) BETWEEN base.begin_time AND base.end_time
                        LEFT JOIN Trans_log_table AS logt ON main.FInterID = logt.FInterID 
                        LEFT JOIN uct_waste_warehouse AS ware ON SUBSTRING(main.FDCStockID, 3) = ware.id
                        WHERE main.FCancellation <> 0 AND ware.parent_id = 0 AND main.FTranType = 'SOR' AND logt.FTranType = 'PUR' AND logt.Tsort BETWEEN base.begin_time AND base.end_time
                               AND main.FSaleStyle = 0 AND logt.TsortOver = 1
                        GROUP BY ware.branch_id
             ) as detail ON ware.branch_id = detail.branch_id;

             EXCEPTION WHEN OTHERS THEN
                 ROLLBACK;
                 o_rv := 1003;
                 o_err := '仓库月数据生成失败: ' || SQLERRM;
                 RETURN;
         END;

         COMMIT;
     EXCEPTION WHEN OTHERS THEN
         ROLLBACK;
         o_rv := 200;
         o_err := '仓库月数据生成成功';
         RETURN;
     END;
END;
$$;



CREATE OR REPLACE PROCEDURE uctoo_lvhuan.one_level_wall_report(region_type varchar(50)) 
LANGUAGE plpgsql
AS $$
DECLARE 
    group_field varchar(50);
    region_where varchar(50);
    nowdate date := now() - interval '1 day';
BEGIN
    nowdate := DATE_TRUNC('day', nowdate);

    IF region_type = 'area' THEN       
        group_field := 'cf.province, cf.city, cf.area';
        region_where := 'ad.name = cf.area';
    ELSIF region_type = 'city' THEN   
        group_field := 'cf.province, cf.city';
        region_where := 'ad.name = cf.city';
    ELSE                                
        group_field := 'cf.province';
        region_where := 'ad.name = cf.province';
    END IF;

    EXECUTE 'INSERT INTO uct_one_level_day_wall_report(adcode, name, weight, carbon, report_date) 
             SELECT ad.adcode, c3.name, ROUND(SUM(FQty)::numeric, 2) AS weight, 
                    ROUND(SUM(FQty * c2.carbon_parm)::numeric, 2) AS carbon, ''' || nowdate || ''' AS report_date
             FROM Trans_main_table mt  
             JOIN Trans_main_table mt2 ON mt.FInterId = mt2.FInterId 
                 AND mt2.FTranType = ''PUR'' AND date(mt2.FDate) > ''2018-09-30'' AND date(mt2.FDate) = date(''' || nowdate || ''')  
             JOIN uct_waste_purchase p ON mt.FBillNo = p.order_id  
             JOIN uct_waste_customer_factory cf ON cf.id = p.factory_id   
             JOIN uct_adcode ad ON ' || region_where || ' 
             JOIN Trans_assist_table at ON mt.FInterID = at.FinterID  AND mt.FTranType = at.FTranType   
             JOIN uct_waste_cate c ON c.id = at.FItemID  
             JOIN uct_waste_cate c2 ON c.parent_id = c2.id  
             JOIN uct_waste_cate c3 ON c2.parent_id = c3.id  
             WHERE mt.FTranType IN (''SOR'', ''SEL'') AND mt.FSaleStyle IN (''0'', ''1'')  
                 AND mt.FCorrent = ''1'' AND mt.FCancellation = ''1''  AND mt.FRelateBrID != 7   
             GROUP BY ' || group_field || ', c3.name 
             ORDER BY weight';

    EXECUTE 'INSERT INTO uct_one_level_accumulate_wall_report(adcode, name, weight, carbon) 
             SELECT ad.adcode, c3.name, ROUND(SUM(FQty)::numeric, 2) AS weight, 
                    ROUND(SUM(FQty * c2.carbon_parm)::numeric, 2) AS carbon
             FROM Trans_main_table mt  
             JOIN Trans_main_table mt2 ON mt.FInterId = mt2.FInterId 
                 AND mt2.FTranType = ''PUR'' AND date(mt2.FDate) > ''2018-09-30'' AND date(mt2.FDate) = date(''' || nowdate || ''')  
             JOIN uct_waste_purchase p ON mt.FBillNo = p.order_id  
             JOIN uct_waste_customer_factory cf ON cf.id = p.factory_id   
             JOIN uct_adcode ad ON ' || region_where || ' 
             JOIN Trans_assist_table at ON mt.FInterID = at.FinterID  AND mt.FTranType = at.FTranType   
             JOIN uct_waste_cate c ON c.id = at.FItemID  
             JOIN uct_waste_cate c2 ON c.parent_id = c2.id  
             JOIN uct_waste_cate c3 ON c2.parent_id = c3.id  
             WHERE mt.FTranType IN (''SOR'', ''SEL'') AND mt.FSaleStyle IN (''0'', ''1'')  
                 AND mt.FCorrent = ''1'' AND mt.FCancellation = ''1''  AND mt.FRelateBrID != 7   
             GROUP BY ' || group_field || ', c3.name 
             ORDER BY weight';

END;
$$;



CREATE OR REPLACE PROCEDURE uctoo_lvhuan.operate_daily_report(_begin_time DATE, _end_time DATE) 
LANGUAGE plpgsql
AS $$
DECLARE
    _test_date DATE := _begin_time;
BEGIN
    -- Start the transaction
    BEGIN
        LOOP
            EXIT WHEN _test_date > _end_time;

            INSERT INTO lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, val1, val2, val3)
            SELECT
                'D' AS time_dims,
                (_test_date - INTERVAL '1 DAY') AS time_val,
                (_test_date - INTERVAL '1 DAY') AS begin_time,
                _test_date AS end_time,
                '角色' AS data_dims,
                a.id AS data_val,
                'operate-daily-report' AS stat_code,
                'stock-in' AS group1,
                ROUND(COALESCE(SUM(mt.TalFQty), 0), 2) AS val1,
                ROUND(COALESCE(SUM(mt.TalFQty), 0), 2) - COALESCE(r.val1, 0) AS val2,
                CASE
                    WHEN COALESCE(r.val1, 0) = 0 THEN 0
                    ELSE ROUND((ROUND(COALESCE(SUM(mt.TalFQty), 0), 2) - COALESCE(r.val1, 0)) / COALESCE(r.val1, 0), 2)
                END AS val3
            FROM Trans_main_table mt
            JOIN Trans_main_table mt2 ON mt.FBillNo = mt2.FBillNo
            RIGHT JOIN lh_dw.data_statistics_results r ON r.data_val = mt2.FEmpID AND mt.FCancellation = '1' AND mt.FCorrent = '1' AND mt.FSaleStyle != '2' AND mt.FTranType IN ('SOR', 'SEL') AND mt2.FTranType = 'PUR' AND mt."Date" = (_test_date - INTERVAL '1 DAY')
            RIGHT JOIN uct_admin a ON CAST(a.id AS TEXT) = r.data_val AND r.time_dims = 'D' AND r.time_val = TO_CHAR(_test_date - INTERVAL '2 DAY', 'YYYY-MM-DD') AND r.data_dims = '角色' AND r.stat_code = 'operate-daily-report' AND r.group1 = 'stock-in'
            JOIN uct_auth_group_access ga ON ga.uid = a.id AND ga.group_id IN (32, 36)
            GROUP BY a.id;

            _test_date := _test_date + INTERVAL '1 DAY';
        END LOOP;
    END;

    -- Commit the transaction
    COMMIT;
END;
$$;




CREATE OR REPLACE PROCEDURE uctoo_lvhuan.order_cancel()
LANGUAGE plpgsql
AS
$$
DECLARE 
    id_field int;
    order_id_field int;
    order_num_field varchar(50);
    type_field varchar(5);
    hand_mouth_data_field int;
    corrent_field int;
    handle_field int;
    order_type varchar(10);
    done BOOLEAN := FALSE;
BEGIN
    -- Loop through the rows using a FOR loop and SELECT directly
    FOR id_field, order_id_field, order_num_field, type_field, hand_mouth_data_field, corrent_field, handle_field IN
        SELECT id, order_id, order_num, type, hand_mouth_data, corrent, handle
        FROM uct_order_cancel
        WHERE handle = 0
    LOOP
        -- Update the handle field
        UPDATE uct_order_cancel SET handle = 1 WHERE id = id_field;

        -- Set the default order type
        order_type := 'PUR,SOR';

        -- Check the type field and update the order type accordingly
        IF type_field = 'SEL' THEN
            order_type := 'SEL';
        END IF;

        -- Update Trans_main_table
        UPDATE Trans_main_table
        SET FCancellation = 0, TalFQty = 0, TalFAmount = 0, TalFrist = 0, TalSecond = 0, TalThird = 0, TalForth = 0, TalFeeFifth = 0, is_hedge = 1, red_ink_time = NOW()
        WHERE FInterID = order_id_field AND FTranType = ANY(string_to_array(order_type, ','));

        -- Update Trans_fee_table
        UPDATE Trans_fee_table
        SET is_hedge = 1
        WHERE FInterID = order_id_field AND FTranType = ANY(string_to_array(order_type, ','));
        
        INSERT INTO Trans_fee_table
        SELECT FInterID, FTranType, Ffeesence, FEntryID, FFeeID, FFeeType, FFeePerson, FFeeExplain, -FFeeAmount, FFeebaseAmount, Ftaxrate, Fbasetax, Fbasetaxamount, FPriceRef, FFeetime, NOW(), is_hedge, revise_state
        FROM Trans_fee_table
        WHERE FInterID = order_id_field AND FTranType = ANY(string_to_array(order_type, ','));

        -- Update Trans_materiel_table
        UPDATE Trans_materiel_table
        SET is_hedge = 1
        WHERE FInterID = order_id_field AND FTranType = ANY(string_to_array(order_type, ','));
        
        INSERT INTO Trans_materiel_table
        SELECT FInterID, FTranType, FEntryID, FMaterielID, -FUseCount, FPrice, -FMeterielAmount, FMeterieltime, NOW(), is_hedge, revise_state
        FROM Trans_materiel_table
        WHERE FInterID = order_id_field AND FTranType = ANY(string_to_array(order_type, ','));

        -- Update Trans_assist_table
        UPDATE Trans_assist_table
        SET is_hedge = 1
        WHERE FinterID = order_id_field AND FTranType = ANY(string_to_array(order_type, ','));
        
        INSERT INTO Trans_assist_table
        SELECT FinterID, FTranType, FEntryID, FItemID, FUnitID, -FQty, FPrice, -FAmount, disposal_way, value_type, FbasePrice, FbaseAmount, Ftaxrate, Fbasetax, Fbasetaxamount, FPriceRef, FDCTime, FSourceInterId, FSourceTranType, NOW(), is_hedge, revise_state
        FROM Trans_assist_table
        WHERE FinterID = order_id_field AND FTranType = ANY(string_to_array(order_type, ','));

        -- Handle the special case when hand_mouth_data_field = 1
        IF hand_mouth_data_field = 1 THEN
            IF type_field = 'PUR' THEN
                order_type := 'SEL';
                SELECT order_type INTO order_type;
                SELECT id INTO order_id_field FROM uct_waste_sell WHERE order_id = order_num_field;
                SELECT order_id_field INTO order_id_field;
            ELSE
                order_type := 'PUR';
                SELECT order_type INTO order_type;
                SELECT id INTO order_id_field FROM uct_waste_purchase WHERE order_id = order_num_field;
                SELECT order_id_field INTO order_id_field;
            END IF;

            -- Update Trans_main_table again
            UPDATE Trans_main_table
            SET FCancellation = 0, TalFQty = 0, TalFAmount = 0, TalFrist = 0, TalSecond = 0, TalThird = 0, TalForth = 0, TalFeeFifth = 0, is_hedge = 1, red_ink_time = NOW()
            WHERE FInterID = order_id_field AND FTranType = ANY(string_to_array(order_type, ','));

            -- Rest of the updates for Trans_fee_table, Trans_materiel_table, and Trans_assist_table remain the same
            -- ...

        END IF;
    END LOOP;
END;
$$;


CREATE OR REPLACE PROCEDURE uctoo_lvhuan.province_wall_report()
LANGUAGE plpgsql
AS
$$
DECLARE 
    nowdate date := NOW();
BEGIN
    nowdate := (SELECT DATE_TRUNC('day', CURRENT_DATE) - INTERVAL '1 day');

    INSERT INTO uct_day_wall_report (adcode, weight, availability, rubbish, rdf, carbon, box, customer_num, report_date)
    SELECT ad.adcode, 
           COALESCE(weight, 0) AS weight, 
           COALESCE(availability, 0) AS availability, 
           COALESCE(rubbish, 0) AS rubbish, 
           COALESCE(rdf, 0) AS rdf,
           COALESCE(carbon, 0) AS carbon,
           COALESCE(box, 0) AS box,
           COALESCE(customer.customer_num, 0) AS customer_num,
           nowdate AS report_date
    FROM uct_adcode ad
    LEFT JOIN (
        SELECT ad.adcode, 
               ROUND(SUM(FQty), 2) AS weight,
               ROUND(SUM(CASE WHEN c.name = '低值废弃物' THEN FQty ELSE 0 END) / SUM(FQty), 2) AS availability,
               ROUND(SUM(CASE WHEN c.name = '低值废弃物' THEN FQty ELSE 0 END), 2) AS rubbish,
               ROUND(SUM(CASE WHEN c.name = '低值废弃物' THEN FQty ELSE 0 END) / SUM(FQty) * 4.2, 2) AS rdf,
               ROUND(SUM(FQty * c2.carbon_parm), 2) AS carbon,
               box.box
        FROM Trans_main_table mt
        JOIN Trans_main_table mt2 ON mt.FInterId = mt2.FInterId AND mt2.FTranType = 'PUR' AND mt2.FDate > '2018-09-30'  AND mt2.FDate = nowdate
        JOIN uct_waste_purchase p ON mt.FBillNo = p.order_id
        JOIN uct_waste_customer_factory cf ON cf.id = p.factory_id
        JOIN uct_adcode ad ON ad.name = cf.province
        JOIN Trans_assist_table at ON mt.FInterID = at.FinterID AND mt.FTranType = at.FTranType
        JOIN uct_waste_cate c ON c.id = at.FItemID
        JOIN uct_waste_cate c2 ON c.parent_id = c2.id
        LEFT JOIN (
            SELECT ad.adcode, SUM(FUseCount) AS box
            FROM Trans_main_table mt
            JOIN uct_waste_purchase p ON mt.FInterID = p.id
            JOIN uct_waste_customer_factory cf ON cf.id = p.factory_id
            JOIN uct_adcode ad ON ad.name = cf.province
            JOIN Trans_materiel_table materiel ON materiel.FInterID = mt.FInterID
            JOIN uct_materiel materiel2 ON materiel.FMaterielID = materiel2.id AND materiel.FTranType IN ('PUR', 'SOR') AND materiel2.name = '分类箱'
            WHERE mt.FDate > '2018-09-30' AND mt.FDate = nowdate AND mt.FTranType = 'PUR' AND mt.FSaleStyle IN ('0', '1') AND mt.FCorrent = '1' AND mt.FCancellation = '1' AND mt.FRelateBrID != 7
            GROUP BY cf.province
        ) box ON box.adcode = ad.adcode
        WHERE mt.FTranType IN ('SOR', 'SEL') AND mt.FSaleStyle IN ('0', '1') AND mt.FCorrent = '1' AND mt.FCancellation = '1' AND mt.FRelateBrID != 7
        GROUP BY cf.province
    ) data ON ad.adcode = data.adcode
    LEFT JOIN (
        SELECT ad.adcode, COUNT(*) AS customer_num
        FROM uct_up up
        JOIN uct_adcode ad ON up.company_province = ad.name AND first_business_time = nowdate
        GROUP BY company_province
    ) customer ON customer.adcode = ad.adcode
    WHERE RIGHT(ad.adcode, 4) = '0000';

    UPDATE uct_accumulate_wall_report report 
    SET weight = data.weight, 
        availability = data.availability, 
        rubbish = data.rubbish, 
        rdf = data.rdf, 
        carbon = data.carbon, 
        box = data.box, 
        customer_num = data.customer_num 
    FROM (
        SELECT ad.adcode, 
               COALESCE(weight, 0) AS weight, 
               COALESCE(availability, 0) AS availability, 
               COALESCE(rubbish, 0) AS rubbish, 
               COALESCE(rdf, 0) AS rdf, 
               COALESCE(carbon, 0) AS carbon, 
               COALESCE(box, 0) AS box, 
               COALESCE(customer.customer_num, 0) AS customer_num
        FROM uct_adcode ad
        LEFT JOIN (
            SELECT ad.adcode, 
                   ROUND(SUM(FQty), 2) AS weight,
                   ROUND(SUM(CASE WHEN c.name = '低值废弃物' THEN FQty ELSE 0 END) / SUM(FQty), 2) AS availability,
                   ROUND(SUM(CASE WHEN c.name = '低值废弃物' THEN FQty ELSE 0 END), 2) AS rubbish,
                   ROUND(SUM(CASE WHEN c.name = '低值废弃物' THEN FQty ELSE 0 END) / SUM(FQty) * 4.2, 2) AS rdf,
                   ROUND(SUM(FQty * c2.carbon_parm), 2) AS carbon,
                   box.box
            FROM Trans_main_table mt
            JOIN Trans_main_table mt2 ON mt.FInterId = mt2.FInterId AND mt2.FTranType = 'PUR' AND mt2.FDate > '2018-09-30'  AND mt2.FDate = nowdate
            JOIN uct_waste_purchase p ON mt.FBillNo = p.order_id
            JOIN uct_waste_customer_factory cf ON cf.id = p.factory_id
            JOIN uct_adcode ad ON ad.name = cf.province
            JOIN Trans_assist_table at ON mt.FInterID = at.FinterID AND mt.FTranType = at.FTranType
            JOIN uct_waste_cate c ON c.id = at.FItemID
            JOIN uct_waste_cate c2 ON c.parent_id = c2.id
            LEFT JOIN (
                SELECT ad.adcode, SUM(FUseCount) AS box
                FROM Trans_main_table mt
                JOIN uct_waste_purchase p ON mt.FInterID = p.id
                JOIN uct_waste_customer_factory cf ON cf.id = p.factory_id
                JOIN uct_adcode ad ON ad.name = cf.province
                JOIN Trans_materiel_table materiel ON materiel.FInterID = mt.FInterID
                JOIN uct_materiel materiel2 ON materiel.FMaterielID = materiel2.id AND materiel.FTranType IN ('PUR', 'SOR') AND materiel2.name = '分类箱'
                WHERE mt.FDate > '2018-09-30' AND mt.FDate = nowdate AND mt.FTranType = 'PUR' AND mt.FSaleStyle IN ('0', '1') AND mt.FCorrent = '1' AND mt.FCancellation = '1' AND mt.FRelateBrID != 7
                GROUP BY cf.province
            ) box ON box.adcode = ad.adcode
            WHERE mt.FTranType IN ('SOR', 'SEL') AND mt.FSaleStyle IN ('0', '1') AND mt.FCorrent = '1' AND mt.FCancellation = '1' AND mt.FRelateBrID != 7
            GROUP BY cf.province
        ) data ON ad.adcode = data.adcode
        LEFT JOIN (
            SELECT ad.adcode, COUNT(*) AS customer_num
            FROM uct_up up
            JOIN uct_adcode ad ON up.company_province = ad.name AND first_business_time = nowdate
            GROUP BY company_province
        ) customer ON customer.adcode = ad.adcode
        WHERE RIGHT(ad.adcode, 4) = '0000'
    ) data 
    WHERE report.adcode = data.adcode;
END;
$$;


CREATE OR REPLACE PROCEDURE uctoo_lvhuan.pur_allot(IN p_id INT, IN p_hand_mouth_data INT, IN p_give_frame INT)
LANGUAGE plpgsql
AS
$$
BEGIN
    IF p_hand_mouth_data = 1 THEN
        PERFORM Trans_log_pur_hand(p_id);
        PERFORM Trans_main_pur(p_id);
    ELSIF p_give_frame = 1 THEN
        PERFORM Trans_log_pur_give(p_id);
        PERFORM Trans_main_pur(p_id);
    ELSE
        PERFORM Trans_log_pur(p_id);
        PERFORM Trans_main_pur(p_id);
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE uctoo_lvhuan.pur_apply_materiel(IN p_id INT, IN p_hand_mouth_data INT, IN p_give_frame INT)
LANGUAGE plpgsql
AS
$$
BEGIN
    IF p_give_frame = 1 THEN
        PERFORM Trans_materiel_pur(p_id);
        PERFORM Trans_log_pur_give(p_id);
        PERFORM Trans_main_pur(p_id);
    ELSE
        PERFORM Trans_materiel_pur(p_id);
        PERFORM Trans_log_pur(p_id);
        PERFORM Trans_main_pur(p_id);
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE uctoo_lvhuan.pur_fillin_return_fee(IN p_pur_id INT)
LANGUAGE plpgsql
AS
$$
DECLARE
    sel_id INT;
BEGIN
    SELECT id INTO sel_id FROM uct_waste_sell WHERE purchase_id = p_pur_id;
    PERFORM Trans_fee_rf(p_pur_id);
    PERFORM Trans_log_pur_hand(p_pur_id);
    PERFORM Trans_main_pur(p_pur_id);
    PERFORM Trans_main_sel_hand(sel_id);
END;
$$;


CREATE OR REPLACE PROCEDURE uctoo_lvhuan.pur_pick_cargo(IN p_id INT, IN p_hand_mouth_data INT, IN p_give_frame INT)
LANGUAGE plpgsql
AS
$$
BEGIN
    IF p_hand_mouth_data = 1 THEN
        PERFORM Trans_fee_pc(p_id);
        PERFORM Trans_assist_pur(p_id);
        PERFORM Trans_log_pur_hand(p_id);
        PERFORM Trans_main_pur(p_id);
    ELSIF p_give_frame = 1 THEN
        PERFORM Trans_fee_pc(p_id);
        PERFORM Trans_assist_pur(p_id);
        PERFORM Trans_log_pur_give(p_id);
        PERFORM Trans_main_pur(p_id);
    ELSE
        PERFORM Trans_fee_pc(p_id);
        PERFORM Trans_assist_pur(p_id);
        PERFORM Trans_log_pur(p_id);
        PERFORM Trans_main_pur(p_id);
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE uctoo_lvhuan.pur_pick_materiel(IN p_id INT, IN p_hand_mouth_data INT, IN p_give_frame INT)
LANGUAGE plpgsql
AS
$$
BEGIN
    IF p_give_frame = 1 THEN
        PERFORM Trans_materiel_pur(p_id);
        PERFORM Trans_log_pur_give(p_id);
        PERFORM Trans_main_pur(p_id);
    ELSE
        PERFORM Trans_materiel_pur(p_id);
        PERFORM Trans_log_pur(p_id);
        PERFORM Trans_main_pur(p_id);
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE uctoo_lvhuan.pur_receive(IN p_id INT, IN p_hand_mouth_data INT, IN p_give_frame INT)
LANGUAGE plpgsql
AS
$$
BEGIN
    IF p_hand_mouth_data = 1 THEN
        PERFORM Trans_log_pur_hand(p_id);
        PERFORM Trans_main_pur(p_id);
    ELSIF p_give_frame = 1 THEN
        PERFORM Trans_log_pur_give(p_id);
        PERFORM Trans_main_pur(p_id);
    ELSE
        PERFORM Trans_log_pur(p_id);
        PERFORM Trans_main_pur(p_id);
    END IF;
END;
$$;

-- pur_return_fee_confirm
CREATE OR REPLACE PROCEDURE uctoo_lvhuan.pur_return_fee_confirm(IN p_pur_id INT, IN p_hand_mouth_data INT, IN p_give_frame INT)
LANGUAGE plpgsql
AS
$$
DECLARE
    sel_id INT;
    cw_id INT;
    cw_createtime INT;
BEGIN
    SELECT admin_id, createtime INTO cw_id, cw_createtime FROM uct_waste_purchase_log WHERE purchase_id = p_pur_id AND state_value = 'wait_confirm_return_fee';

    IF p_hand_mouth_data = 1 THEN
        SELECT id INTO sel_id FROM uct_waste_sell WHERE purchase_id = p_pur_id;
        PERFORM Trans_log_pur_hand(p_pur_id);

        UPDATE Trans_main_table SET FStatus = 1, FNowState = 'finish', FCheckerID = cw_id, FCheckDate = cw_createtime WHERE FInterID = p_pur_id AND FTranType = 'PUR';
        UPDATE Trans_main_table SET FStatus = 1, FNowState = 'finish', FCheckerID = cw_id, FCheckDate = cw_createtime WHERE FInterID = sel_id AND FTranType = 'SEL';
    ELSE
        PERFORM Trans_log_pur(p_pur_id);

        UPDATE Trans_main_table SET FStatus = 1, FNowState = 'finish', FCheckerID = cw_id, FCheckDate = cw_createtime WHERE FInterID = p_pur_id AND FTranType IN ('PUR', 'SOR');
    END IF;
END;
$$;


-- pur_signin_materiel
CREATE OR REPLACE PROCEDURE uctoo_lvhuan.pur_signin_materiel(IN p_id INT, IN p_hand_mouth_data INT, IN p_give_frame INT)
LANGUAGE plpgsql
AS
$$
BEGIN
    IF p_give_frame = 1 THEN
        PERFORM Trans_log_pur_give(p_id);
        PERFORM Trans_main_pur(p_id);
    ELSE
        PERFORM Trans_log_pur(p_id);
        PERFORM Trans_main_pur(p_id);
    END IF;
END;
$$;


-- pur_storage_confirm
CREATE OR REPLACE PROCEDURE uctoo_lvhuan.pur_storage_confirm(IN p_id INT)
LANGUAGE plpgsql
AS
$$
BEGIN
    PERFORM Trans_log_pur(p_id);
    PERFORM Trans_main_pur(p_id);
    PERFORM Trans_main_sor(p_id);
END;
$$;


-- pur_storage_connect
CREATE OR REPLACE PROCEDURE uctoo_lvhuan.pur_storage_connect(IN p_id INT, IN p_hand_mouth_data INT, IN p_give_frame INT)
LANGUAGE plpgsql
AS
$$
BEGIN
    IF p_give_frame = 1 THEN
        PERFORM Trans_fee_so(p_id);
        PERFORM Trans_materiel_pur(p_id);
        PERFORM Trans_log_pur_give(p_id);
        PERFORM Trans_main_pur(p_id);
        PERFORM Trans_main_sor(p_id);
    ELSE
        PERFORM Trans_fee_so(p_id);
        PERFORM Trans_materiel_pur(p_id);
        PERFORM Trans_log_pur(p_id);
        PERFORM Trans_main_pur(p_id);
        PERFORM Trans_main_sor(p_id);
    END IF;
END;
$$;


-- pur_storage_connect_confirm
CREATE OR REPLACE PROCEDURE uctoo_lvhuan.pur_storage_connect_confirm(IN p_id INT, IN p_hand_mouth_data INT, IN p_give_frame INT)
LANGUAGE plpgsql
AS
$$
BEGIN
    IF p_give_frame = 1 THEN
        PERFORM Trans_fee_rf(p_id);
        PERFORM Trans_log_pur_give(p_id);
        PERFORM Trans_main_pur(p_id);
        PERFORM Trans_main_sor(p_id);
    ELSE
        PERFORM Trans_fee_rf(p_id);
        PERFORM Trans_log_pur(p_id);
        PERFORM Trans_main_pur(p_id);
        PERFORM Trans_main_sor(p_id);
    END IF;
END;
$$;


-- pur_storage_sort
CREATE OR REPLACE PROCEDURE uctoo_lvhuan.pur_storage_sort(IN p_id INT)
LANGUAGE plpgsql
AS
$$
BEGIN
    PERFORM Trans_fee_ss(p_id);
    PERFORM Trans_assist_sor(p_id);
    PERFORM Trans_materiel_sor(p_id);
    PERFORM Trans_log_pur(p_id);
    PERFORM Trans_main_pur(p_id);
    PERFORM Trans_main_sor(p_id);
END;
$$;


-- p_constitute_forCustomer_report
CREATE OR REPLACE PROCEDURE uctoo_lvhuan.p_constitute_forCustomer_report()
LANGUAGE plpgsql
AS
$$
BEGIN
    START TRANSACTION;
    INSERT INTO Trans_constitute_forCustomer_table SELECT * FROM Trans_constitute_forCustomer;
    COMMIT;
END;
$$;


-- p_forCustomer_report
CREATE OR REPLACE PROCEDURE uctoo_lvhuan.p_forCustomer_report()
LANGUAGE plpgsql
AS
$$
BEGIN
    START TRANSACTION;
    INSERT INTO Trans_forCustomer_table SELECT * FROM Trans_forCustomer;
    COMMIT;
END;
$$;


-- p_INVforDep_day_report
CREATE OR REPLACE PROCEDURE uctoo_lvhuan.p_INVforDep_day_report()
LANGUAGE plpgsql
AS
$$
BEGIN
    START TRANSACTION;
    DELETE FROM Trans_daily_INVforDep_table;
    INSERT INTO Trans_daily_INVforDep_table SELECT * FROM Trans_daily_INVforDep;
    COMMIT;
END;
$$;


-- p_INVforDep_month_report
CREATE OR REPLACE PROCEDURE uctoo_lvhuan.p_INVforDep_month_report()
LANGUAGE plpgsql
AS
$$
BEGIN
    START TRANSACTION;
    INSERT INTO Trans_month_INVforDep_table SELECT * FROM Trans_month_INVforDep;
    COMMIT;
END;
$$;


-- p_profit_day_report
CREATE OR REPLACE PROCEDURE uctoo_lvhuan.p_profit_day_report()
LANGUAGE plpgsql
AS
$$
BEGIN
    START TRANSACTION;
    DELETE FROM Trans_daily_WH_profit_table;
    INSERT INTO Trans_daily_WH_profit_table SELECT * FROM Trans_daily_WH_profit;
    COMMIT;
END;
$$;


-- p_profit_month_report
CREATE OR REPLACE PROCEDURE uctoo_lvhuan.p_profit_month_report()
LANGUAGE plpgsql
AS
$$
BEGIN
    START TRANSACTION;
    INSERT INTO Trans_month_WH_profit_table SELECT * FROM Trans_month_WH_profit;
    COMMIT;
END;
$$;



-- p_purchase_day_report
CREATE OR REPLACE PROCEDURE uctoo_lvhuan.p_purchase_day_report()
LANGUAGE plpgsql
AS
$$
BEGIN
    START TRANSACTION;
    DELETE FROM Trans_daily_SOR_table;
    INSERT INTO Trans_daily_SOR_table SELECT * FROM Trans_daily_SOR;
    COMMIT;
END;
$$;


-- p_purchase_month_report
CREATE OR REPLACE PROCEDURE uctoo_lvhuan.p_purchase_month_report()
LANGUAGE plpgsql
AS
$$
BEGIN
    START TRANSACTION;
    INSERT INTO Trans_month_SOR_table SELECT * FROM Trans_month_SOR;
    COMMIT;
END;
$$;


-- p_sel_day_report
CREATE OR REPLACE PROCEDURE uctoo_lvhuan.p_sel_day_report()
LANGUAGE plpgsql
AS
$$
BEGIN
    START TRANSACTION;
    DELETE FROM Trans_daily_SEL_table;
    INSERT INTO Trans_daily_SEL_table SELECT * FROM Trans_daily_SEL;
    COMMIT;
END;
$$;


-- p_sel_month_report
CREATE OR REPLACE PROCEDURE uctoo_lvhuan.p_sel_month_report()
LANGUAGE plpgsql
AS
$$
BEGIN
    START TRANSACTION;
    INSERT INTO Trans_month_SEL_table SELECT * FROM Trans_month_SEL;
    COMMIT;
END;
$$;


-- p_sel_rank_month_report
CREATE OR REPLACE PROCEDURE uctoo_lvhuan.p_sel_rank_month_report()
LANGUAGE plpgsql
AS
$$
BEGIN
    START TRANSACTION;
    INSERT INTO Trans_month_SEL_rank_table SELECT * FROM Trans_month_SEL_rank;
    COMMIT;
END;
$$;


CREATE OR REPLACE PROCEDURE uctoo_lvhuan.region_wall_report()
LANGUAGE plpgsql
AS
$$
DECLARE
    nowdate date := CURRENT_DATE - INTERVAL '1 day';
BEGIN
    INSERT INTO uct_day_wall_report (adcode, weight, availability, rubbish, rdf, carbon, box, customer_num, report_date)
    SELECT
        ad.adcode,
        COALESCE(weight, 0) AS weight,
        COALESCE(availability, 0) AS availability,
        COALESCE(rubbish, 0) AS rubbish,
        COALESCE(rdf, 0) AS rdf,
        COALESCE(carbon, 0) AS carbon,
        COALESCE(box, 0) AS box,
        COALESCE(customer.customer_num, 0) AS customer_num,
        nowdate AS report_date
    FROM
        uct_adcode ad
    LEFT JOIN (
        SELECT
            ad.adcode,
            round(sum(FQty), 2) AS weight,
            round(sum(if(c.name = '低值废弃物', FQty, 0)) / sum(FQty), 2) AS availability,
            round(sum(if(c.name = '低值废弃物', FQty, 0)), 2) AS rubbish,
            round(sum(if(c.name = '低值废弃物', FQty, 0)) / sum(FQty) * 4.2, 2) AS rdf,
            round(sum(FQty * c2.carbon_parm), 2) AS carbon,
            box.box
        FROM
            Trans_main_table mt
            JOIN Trans_main_table mt2 ON mt.FInterId = mt2.FInterId AND mt2.FTranType = 'PUR' AND date_trunc('day', mt2.FDate) > '2018-09-30' AND date_trunc('day', mt2.FDate) = date_trunc('day', nowdate)
            JOIN uct_waste_purchase p ON mt.FBillNo = p.order_id
            JOIN uct_waste_customer_factory cf ON cf.id = p.factory_id
            JOIN uct_adcode ad ON ad.name = cf.area
            JOIN Trans_assist_table at ON mt.FInterID = at.FinterID AND mt.FTranType = at.FTranType
            JOIN uct_waste_cate c ON c.id = at.FItemID
            JOIN uct_waste_cate c2 ON c.parent_id = c2.id
            LEFT JOIN (
                SELECT
                    ad.adcode,
                    sum(FUseCount) AS box
                FROM
                    Trans_main_table mt
                    JOIN uct_waste_purchase p ON mt.FInterID = p.id
                    JOIN uct_waste_customer_factory cf ON cf.id = p.factory_id
                    JOIN uct_adcode ad ON ad.name = cf.area
                    JOIN Trans_materiel_table materiel ON materiel.FInterID = mt.FInterID
                    JOIN uct_materiel materiel2 ON materiel.FMaterielID = materiel2.id AND materiel.FTranType IN ('PUR', 'SOR') AND materiel2.name = '分类箱'
                WHERE
                    date_trunc('day', mt.FDate) > '2018-09-30' AND date_trunc('day', mt.FDate) = date_trunc('day', nowdate) AND mt.FTranType = 'PUR'
                    AND mt.FSaleStyle IN ('0', '1') AND mt.FCorrent = '1' AND mt.FCancellation = '1' AND mt.FRelateBrID != 7
                GROUP BY
                    cf.province,
                    cf.city,
                    cf.area
            ) box ON box.adcode = ad.adcode
        WHERE
            mt.FTranType IN ('SOR', 'SEL') AND mt.FSaleStyle IN ('0', '1') AND mt.FCorrent = '1' AND mt.FCancellation = '1' AND mt.FRelateBrID != 7
        GROUP BY
            cf.province,
            cf.city,
            cf.area
    ) data ON ad.adcode = data.adcode
    LEFT JOIN (
        SELECT
            ad.adcode,
            count(*) AS customer_num
        FROM
            uct_up up
            JOIN uct_adcode ad ON up.company_region = ad.name AND date_trunc('day', first_business_time) = date_trunc('day', nowdate)
        GROUP BY
            company_province,
            company_city,
            company_region
    ) customer ON customer.adcode = ad.adcode
    WHERE
        right(ad.adcode, 4) != '0000' AND right(ad.adcode, 2) != '00';

    UPDATE uct_accumulate_wall_report report
    SET
        weight = data.weight,
        availability = data.availability,
        rubbish = data.rubbish,
        rdf = data.rdf,
        carbon = data.carbon,
        box = data.box,
        customer_num = data.customer_num
    FROM (
        SELECT
            ad.adcode,
            COALESCE(weight, 0) AS weight,
            COALESCE(availability, 0) AS availability,
            COALESCE(rubbish, 0) AS rubbish,
            COALESCE(rdf, 0) AS rdf,
            COALESCE(carbon, 0) AS carbon,
            COALESCE(box, 0) AS box,
            COALESCE(customer.customer_num, 0) AS customer_num
        FROM
            uct_adcode ad
        LEFT JOIN (
            SELECT
                ad.adcode,
                round(sum(FQty), 2) AS weight,
                round(sum(if(c.name = '低值废弃物', FQty, 0)) / sum(FQty), 2) AS availability,
                round(sum(if(c.name = '低值废弃物', FQty, 0)), 2) AS rubbish,
                round(sum(if(c.name = '低值废弃物', FQty, 0)) / sum(FQty) * 4.2, 2) AS rdf,
                round(sum(FQty * c2.carbon_parm), 2) AS carbon,
                box.box
            FROM
                Trans_main_table mt
                JOIN Trans_main_table mt2 ON mt.FInterId = mt2.FInterId AND mt2.FTranType = 'PUR' AND date_trunc('day', mt2.FDate) > '2018-09-30'
                JOIN uct_waste_purchase p ON mt.FBillNo = p.order_id
                JOIN uct_waste_customer_factory cf ON cf.id = p.factory_id
                JOIN uct_adcode ad ON ad.name = cf.area
                JOIN Trans_assist_table at ON mt.FInterID = at.FinterID AND mt.FTranType = at.FTranType
                JOIN uct_waste_cate c ON c.id = at.FItemID
                JOIN uct_waste_cate c2 ON c.parent_id = c2.id
                LEFT JOIN (
                    SELECT
                        ad.adcode,
                        sum(FUseCount) AS box
                    FROM
                        Trans_main_table mt
                        JOIN uct_waste_purchase p ON mt.FInterID = p.id
                        JOIN uct_waste_customer_factory cf ON cf.id = p.factory_id
                        JOIN uct_adcode ad ON ad.name = cf.area
                        JOIN Trans_materiel_table materiel ON materiel.FInterID = mt.FInterID
                        JOIN uct_materiel materiel2 ON materiel.FMaterielID = materiel2.id AND materiel.FTranType IN ('PUR', 'SOR') AND materiel2.name = '分类箱'
                    WHERE
                        date_trunc('day', mt.FDate) > '2018-09-30' AND mt.FTranType = 'PUR'
                        AND mt.FSaleStyle IN ('0', '1') AND mt.FCorrent = '1' AND mt.FCancellation = '1' AND mt.FRelateBrID != 7
                    GROUP BY
                        cf.province,
                        cf.city,
                        cf.area
                ) box ON box.adcode = ad.adcode
            WHERE
                mt.FTranType IN ('SOR', 'SEL') AND mt.FSaleStyle IN ('0', '1') AND mt.FCorrent = '1' AND mt.FCancellation = '1' AND mt.FRelateBrID != 7
            GROUP BY
                cf.province,
                cf.city,
                cf.area
        ) data ON ad.adcode = data.adcode
        LEFT JOIN (
            SELECT
                ad.adcode,
                count(*) AS customer_num
            FROM
                uct_up up
                JOIN uct_adcode ad ON up.company_region = ad.name
            GROUP BY
                company_province,
                company_city,
                company_region
        ) customer ON customer.adcode = ad.adcode
        WHERE
            right(ad.adcode, 4) = '0000' AND right(ad.adcode, 2) != '00'
    ) data
    WHERE
        report.adcode = data.adcode;
END;
$$;


CREATE OR REPLACE PROCEDURE uctoo_lvhuan.sales_daily_report(_begin_time DATE, _end_time DATE)
LANGUAGE plpgsql
AS
$$
DECLARE
    _test_date DATE := _begin_time;
BEGIN
    LOOP
        EXIT WHEN _test_date > _end_time;

        -- Insert stock-out data
        INSERT INTO lh_dw.data_statistics_results(time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, val1, val2, val3)
        SELECT 'D' AS time_dims, _test_date - INTERVAL '1 DAY' AS time_val,
               (_test_date - INTERVAL '1 DAY')::DATETIME AS begin_time,
               (_test_date)::DATETIME AS end_time,
               '分部' AS data_dims, b.setting_key AS data_val,
               'sales-daily-report' AS stat_code,
               'stock-out' AS group1,
               ROUND(COALESCE(SUM(COALESCE(mt.TalFQty, 0)), 0), 2) AS val1,
               ROUND(COALESCE(SUM(COALESCE(mt.TalFQty, 0)), 0) - COALESCE(r.val1, 0), 2) AS val2,
               COALESCE(ROUND((COALESCE(SUM(COALESCE(mt.TalFQty, 0)), 0) - COALESCE(r.val1, 0)) / COALESCE(r.val1, 0), 2), 0) * 100 AS val3
        FROM uct_branch AS b
        LEFT JOIN (SELECT FRelateBrID, DATE - INTERVAL '1 DAY' AS Date, SUM(COALESCE(TalFQty, 0)) AS val1
                   FROM Trans_main_table
                   WHERE FCancellation = '1'
                     AND FCorrent = '1'
                     AND FSaleStyle IN ('1', '2')
                     AND FTranType = 'SEL'
                     AND "Date" = (_test_date - INTERVAL '1 DAY')
                   GROUP BY FRelateBrID, Date) AS r ON b.setting_key = r.FRelateBrID
        WHERE b.setting_key IS NOT NULL
        GROUP BY b.setting_key;

        -- Insert sales amount data
        INSERT INTO lh_dw.data_statistics_results(time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, val1, val2, val3)
        SELECT 'D' AS time_dims, _test_date - INTERVAL '1 DAY' AS time_val,
               (_test_date - INTERVAL '1 DAY')::DATETIME AS begin_time,
               (_test_date)::DATETIME AS end_time,
               '分部' AS data_dims, b.setting_key AS data_val,
               'sales-daily-report' AS stat_code,
               'sales-amount' AS group1,
               ROUND(COALESCE(SUM(COALESCE(mt.TalFAmount + mt.TalFrist + mt.TalSecond, 0)), 0), 2) AS val1,
               ROUND(COALESCE(SUM(COALESCE(mt.TalFAmount + mt.TalFrist + mt.TalSecond, 0)), 0) - COALESCE(r.val1, 0), 2) AS val2,
               COALESCE(ROUND((COALESCE(SUM(COALESCE(mt.TalFAmount + mt.TalFrist + mt.TalSecond, 0)), 0) - COALESCE(r.val1, 0)) / COALESCE(r.val1, 0), 2), 0) * 100 AS val3
        FROM uct_branch AS b
        LEFT JOIN (SELECT FRelateBrID, DATE - INTERVAL '1 DAY' AS Date, SUM(COALESCE(TalFAmount + TalFrist + TalSecond, 0)) AS val1
                   FROM Trans_main_table
                   WHERE FCancellation = '1'
                     AND FCorrent = '1'
                     AND FSaleStyle IN ('1', '2')
                     AND FTranType = 'SEL'
                     AND "Date" = (_test_date - INTERVAL '1 DAY')
                   GROUP BY FRelateBrID, Date) AS r ON b.setting_key = r.FRelateBrID
        WHERE b.setting_key IS NOT NULL
        GROUP BY b.setting_key;

        -- Insert sales planning count data
        INSERT INTO lh_dw.data_statistics_results(time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, val1)
        SELECT 'D' AS time_dims, _test_date - INTERVAL '1 DAY' AS time_val,
               (_test_date - INTERVAL '1 DAY')::DATETIME AS begin_time,
               (_test_date)::DATETIME AS end_time,
               '分部' AS data_dims, b.setting_key AS data_val,
               'sales-daily-report' AS stat_code,
               'sales-planning-count' AS group1,
               COUNT(ali.id) AS val1
        FROM uct_waste_cate_actual_log AS al
        JOIN uct_waste_cate_actual_log_item AS ali ON al.id = ali.actual_log_id
              AND al.status = 5
              AND ali.state = 1
              AND DATE_PART('EPOCH', TO_TIMESTAMP(ali.start_time))::DATE = (_test_date - INTERVAL '1 DAY')
        RIGHT JOIN uct_branch AS b ON b.setting_key = al.branch_id
        WHERE b.setting_key IS NOT NULL
        GROUP BY b.setting_key;

        -- Insert sales order count data
        INSERT INTO lh_dw.data_statistics_results(time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, val1)
        SELECT 'D' AS time_dims, _test_date - INTERVAL '1 DAY' AS time_val,
               (_test_date - INTERVAL '1 DAY')::DATETIME AS begin_time,
               (_test_date)::DATETIME AS end_time,
               '分部' AS data_dims, b.setting_key AS data_val,
               'sales-daily-report' AS stat_code,
               'sales-order-count' AS group1,
               COUNT(mt.FBillNo) AS val1
        FROM Trans_main_table mt
        RIGHT JOIN lh_dw.data_statistics_results AS r ON r.data_val = mt.FRelateBrID
              AND mt.FCancellation = '1'
              AND mt.FCorrent = '1'
              AND mt.FSaleStyle = '2'
              AND mt.FTranType = 'SEL'
              AND mt."Date" = (_test_date - INTERVAL '1 DAY')
        RIGHT JOIN uct_branch AS b ON b.setting_key = r.data_val
        WHERE b.setting_key IS NOT NULL
        GROUP BY b.setting_key;

        -- Insert direct sale order count data
    
        INSERT INTO lh_dw.data_statistics_results(time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, val1)
        SELECT 'D' AS time_dims, _test_date - INTERVAL '1 DAY' AS time_val,
               (_test_date - INTERVAL '1 DAY')::DATETIME AS begin_time,
               (_test_date)::DATETIME AS end_time,
               '分部' AS data_dims, b.setting_key AS data_val,
               'sales-daily-report' AS stat_code,
               'direct-sale-order-count' AS group1,
               COUNT(mt.FBillNo) AS val1
        FROM Trans_main_table mt
        RIGHT JOIN lh_dw.data_statistics_results AS r ON r.data_val = mt.FRelateBrID
              AND mt.FCancellation = '1'
              AND mt.FSaleStyle = '1'
              AND mt.FTranType = 'PUR'
              AND mt."Date" = (_test_date - INTERVAL '1 DAY')
        RIGHT JOIN uct_branch AS b ON b.setting_key = r.data_val
        WHERE b.setting_key IS NOT NULL
        GROUP BY b.setting_key;

        -- Insert customer cooperation data
        INSERT INTO lh_dw.data_statistics_results(time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, val1, val2, val3)
        SELECT 'D' AS time_dims, _test_date - INTERVAL '1 DAY' AS time_val,
               (_test_date - INTERVAL '1 DAY')::DATETIME AS begin_time,
               (_test_date)::DATETIME AS end_time,
               '分部' AS data_dims, b.setting_key AS data_val,
               'sales-daily-report' AS stat_code,
               'customer-cooperation' AS group1,
               COUNT(at.FItemID) AS val1,
               COUNT(ali.cate_id) AS val2,
               COALESCE(ROUND(COUNT(at.FItemID) / COUNT(ali.cate_id) * 100, 2), 0) AS val3
        FROM Trans_main_table mt
        JOIN Trans_assist_table at ON mt.FInterID = at.FinterID
              AND at.FTranType = mt.FTranType
              AND at.FTranType = 'SEL'
              AND mt.FCancellation = 1
              AND mt.FSaleStyle = 2
              AND mt.FTranType = 'SEL'
              AND mt."Date" = (_test_date - INTERVAL '1 DAY')
        RIGHT JOIN uct_waste_cate_actual_log_item AS ali ON ali.cate_id = at.FItemID
              AND ali.customer_id = mt.FSupplyID
        JOIN uct_waste_cate c ON c.id = ali.cate_id
        RIGHT JOIN uct_branch AS b ON b.setting_key = c.branch_id
              AND DATE_PART('EPOCH', TO_TIMESTAMP(ali.start_time))::DATE = (_test_date - INTERVAL '1 DAY')
        GROUP BY b.setting_key;

        -- Insert sales order detail list data
        INSERT INTO lh_dw.data_statistics_results(time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, group3, txt1, val1, val2, val3)
        SELECT 'D' AS time_dims, _test_date - INTERVAL '1 DAY' AS time_val,
               (_test_date - INTERVAL '1 DAY')::DATETIME AS begin_time,
               (_test_date)::DATETIME AS end_time,
               '分部' AS data_dims, mt.FRelateBrID AS data_val,
               'sales-daily-report' AS stat_code,
               'sales-order-detail-list' AS group1,
               mt.FBillNo AS group2,
               c.name AS group3,
               CASE mt.FSaleStyle
                   WHEN '1' THEN '直销'
                   WHEN '2' THEN '销售出库'
               END AS txt1,
               ROUND(COALESCE(SUM(COALESCE(mt.TalFQty, 0)), 0), 2) AS val1,
               ROUND(COALESCE(SUM(COALESCE(mt.TalFAmount + mt.TalFrist + mt.TalSecond, 0)), 0), 2) AS val2,
               CASE ev.active WHEN 1 THEN 1 ELSE 0 END AS val3
        FROM Trans_main_table mt
        JOIN uct_waste_customer c ON mt.FSupplyID = c.id
              AND mt.FCancellation = '1'
              AND mt.FCorrent = '1'
              AND mt.FTranType = 'SEL'
              AND mt."Date" = (_test_date - INTERVAL '1 DAY')
        LEFT JOIN uct_waste_sell_evidence_voucher ev ON ev.sell_id = mt.FInterID
        GROUP BY mt.FBillNo, c.name, mt.FRelateBrID, ev.active;

        -- Insert price increase data
        INSERT INTO lh_dw.data_statistics_results(time_dims, time_val, begin_time, end_time, data_dims, stat_code, group1, group2, val1, val2)
        SELECT rows.time_dims, rows.time_val, rows.begin_time, rows.end_time, rows.data_dims,
               rows.stat_code, rows.group1, rows.group2, rows.val1, rows.val2
        FROM (SELECT 'D' AS time_dims,
                     _test_date - INTERVAL '1 DAY' AS time_val,
                     (_test_date - INTERVAL '1 DAY')::DATETIME AS begin_time,
                     (_test_date)::DATETIME AS end_time,
                     '分部' AS data_dims,
                     c.branch_id AS data_val,
                     'sales-daily-report' AS stat_code,
                     'price-increase' AS group1,
                     c.name AS group2,
                     ROUND(COALESCE(cl.value, 0), 3) AS val1,
                     ROUND(COALESCE(cl.value, 0) - COALESCE(cl.before_value, 0), 3) AS val2
              FROM uct_waste_cate_log cl
              JOIN uct_waste_cate c ON c.id = cl.cate_id
              WHERE cl.createtime BETWEEN EXTRACT(EPOCH FROM (_test_date - INTERVAL '1 DAY')) AND EXTRACT(EPOCH FROM _test_date)
                AND ROUND(COALESCE(cl.value, 0), 3) > ROUND(COALESCE(cl.before_value, 0), 3)
              ORDER BY c.branch_id, (COALESCE(cl.value, 0) - COALESCE(cl.before_value, 0)) / COALESCE(cl.before_value, 0) * 100 DESC) AS rows;

        -- Insert price decline data
        INSERT INTO lh_dw.data_statistics_results(time_dims, time_val, begin_time, end_time, data_dims, stat_code, group1, group2, val1, val2)
        SELECT rows.time_dims, rows.time_val, rows.begin_time, rows.end_time, rows.data_dims,
               rows.stat_code, rows.group1, rows.group2, rows.val1, rows.val2
                FROM (SELECT 'D' AS time_dims,
                     _test_date - INTERVAL '1 DAY' AS time_val,
                     (_test_date - INTERVAL '1 DAY')::DATETIME AS begin_time,
                     (_test_date)::DATETIME AS end_time,
                     '分部' AS data_dims,
                     c.branch_id AS data_val,
                     'sales-daily-report' AS stat_code,
                     'price-decline' AS group1,
                     c.name AS group2,
                     ROUND(COALESCE(cl.value, 0), 3) AS val1,
                     ROUND(COALESCE(cl.before_value, 0) - COALESCE(cl.value, 0), 3) AS val2
              FROM uct_waste_cate_log cl
              JOIN uct_waste_cate c ON c.id = cl.cate_id
              WHERE cl.createtime BETWEEN EXTRACT(EPOCH FROM (_test_date - INTERVAL '1 DAY')) AND EXTRACT(EPOCH FROM _test_date)
                AND ROUND(COALESCE(cl.value, 0), 3) < ROUND(COALESCE(cl.before_value, 0), 3)
              ORDER BY c.branch_id, (COALESCE(cl.before_value, 0) - COALESCE(cl.value, 0)) / COALESCE(cl.before_value, 0) * 100 DESC) AS rows;

        -- Increment date
        _test_date := _test_date + INTERVAL '1 DAY';
    END LOOP;
END;
$$;

CREATE OR REPLACE PROCEDURE uctoo_lvhuan.sel_add(IN id INT, IN pur_id INT) 
LANGUAGE plpgsql
AS $$
DECLARE 
  move INT := 0;
BEGIN
  IF pur_id IS NOT NULL THEN
    PERFORM Trans_fee_sl(id);
    PERFORM Trans_assist_sel(id);
    PERFORM Trans_materiel_sel(id);
    PERFORM Trans_log_pur_hand(pur_id);
    PERFORM Trans_main_sel_hand(id);
    PERFORM Trans_materiel_pur(pur_id);
  ELSE 
    SELECT is_move INTO move FROM uct_waste_sell AS s WHERE s.id = id;
    IF move = 1 THEN
      PERFORM Trans_assist_sel(id);
    END IF;
    PERFORM Trans_materiel_sel(id);
    PERFORM Trans_log_sel(id);
    PERFORM Trans_main_sel(id);
  END IF; 
END;
$$;


CREATE OR REPLACE PROCEDURE uctoo_lvhuan.sel_commit_order(IN id INT, IN pur_id INT) 
LANGUAGE plpgsql
AS $$
BEGIN
  PERFORM Trans_log_pur_hand(pur_id);
  PERFORM Trans_main_sel_hand(id);
END;
$$;


CREATE OR REPLACE PROCEDURE uctoo_lvhuan.sel_confirm_gather(IN id INT, IN pur_id INT) 
LANGUAGE plpgsql
AS $$
BEGIN
  IF pur_id IS NOT NULL THEN 
    PERFORM Trans_log_pur_hand(pur_id);
    PERFORM Trans_main_sel_hand(id);
  ELSE
    PERFORM Trans_log_sel(id);
    UPDATE Trans_main_table SET FNowState = 'finish' WHERE FInterID = id AND FTranType = 'SEL';
  END IF; 
END;
$$;


CREATE OR REPLACE PROCEDURE uctoo_lvhuan.sel_confirm_order(IN id INT) 
LANGUAGE plpgsql
AS $$
BEGIN
  PERFORM Trans_log_sel(id);
  PERFORM Trans_main_sel(id);
END;
$$;


CREATE OR REPLACE PROCEDURE uctoo_lvhuan.sel_weigh(IN id INT) 
LANGUAGE plpgsql
AS $$
BEGIN
  PERFORM Trans_materiel_sel(id);
  PERFORM Trans_assist_sel(id);
  PERFORM Trans_fee_sl(id);
  PERFORM Trans_log_sel(id);
  PERFORM Trans_main_sel(id);
END;
$$;


CREATE OR REPLACE PROCEDURE sorting_daily_report(_begin_time DATE, _end_time DATE)
LANGUAGE plpgsql
AS $$
DECLARE
    _test_date DATE := _begin_time;
BEGIN
    LOOP
        EXIT WHEN _test_date > _end_time;

        -- Part 1: First Insert Statement
        INSERT INTO lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, val1, val2, val3)
        SELECT 'D' AS time_dims,
               (_test_date - INTERVAL '1 DAY') AS time_val,
               (_test_date - INTERVAL '2 DAY') AS begin_time,
               _test_date AS end_time,
               '角色' AS data_dims,
               a.id AS data_val,
               'sorting-daily-report' AS stat_code,
               'weight' AS group1,
               ROUND(SUM(COALESCE(at.FQty, 0)), 2) AS val1,
               ROUND(SUM(COALESCE(at.FQty, 0)), 2) - COALESCE(r.val1, 0) AS val2,
               COALESCE(ROUND((ROUND(SUM(COALESCE(at.FQty, 0)), 2) - COALESCE(r.val1, 0)) / COALESCE(r.val1, 0), 2), 0) * 100 AS val3
        FROM Trans_assist_table at
        JOIN Trans_main_table mt ON mt.FInterID = at.FinterID AND mt.FTranType = at.FTranType AND mt.FCancellation = '1' AND mt.FSaleStyle = '0' AND mt.FTranType = 'SOR' AND DATE_TRUNC('day', at.FDCTime) = (_test_date - INTERVAL '1 DAY')
        RIGHT JOIN lh_dw.data_statistics_results r ON r.data_val = mt.FEmpID AND r.time_dims = 'D' AND r.time_val = (_test_date - INTERVAL '2 DAY') AND r.data_dims = '角色' AND r.stat_code = 'sorting-daily-report' AND r.group1 = 'weight'
        JOIN uct_admin a ON CAST(a.id AS TEXT) = r.data_val
        JOIN uct_auth_group_access ga ON ga.uid = a.id AND ga.group_id = 42
        GROUP BY a.id;

        -- Part 2: Second Insert Statement
        INSERT INTO lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, val1, val2, val3, val4)
        SELECT 'D' AS time_dims,
               (_test_date - INTERVAL '1 DAY') AS time_val,
               (_test_date - INTERVAL '2 DAY') AS begin_time,
               _test_date AS end_time,
               '角色' AS data_dims,
               a.id AS data_val,
               'sorting-daily-report' AS stat_code,
               'weight-by-waste-structure' AS group1,
               'RW' AS group2,
               ROUND(SUM(COALESCE(at.FQty, 0)), 2) AS val1,
               ROUND(SUM(COALESCE(at.FQty, 0)), 2) - COALESCE(r.val1, 0) AS val2,
               COALESCE(ROUND((ROUND(SUM(COALESCE(at.FQty, 0)), 2) - COALESCE(r.val1, 0)) / COALESCE(r.val1, 0), 2), 0) * 100 AS val3,
               RANK() OVER (ORDER BY SUM(COALESCE(at.FQty, 0)) DESC) AS val4
        FROM Trans_assist_table at
        JOIN Trans_main_table mt ON mt.FInterID = at.FinterID AND mt.FTranType = at.FTranType AND mt.FCancellation = '1' AND mt.FSaleStyle = '0' AND mt.FTranType = 'SOR' AND DATE_TRUNC('day', at.FDCTime) = (_test_date - INTERVAL '1 DAY')
        RIGHT JOIN lh_dw.data_statistics_results r ON r.data_val = mt.FEmpID AND at.value_type = 'valuable' AND r.time_dims = 'D' AND r.time_val = (_test_date - INTERVAL '2 DAY') AND r.data_dims = '角色' AND r.stat_code = 'sorting-daily-report' AND r.group1 = 'weight-by-waste-structure' AND r.group2 = 'RW'
        JOIN uct_admin a ON CAST(a.id AS TEXT) = r.data_val
        JOIN uct_auth_group_access ga ON ga.uid = a.id AND ga.group_id = 42
        GROUP BY a.id
        ORDER BY SUM(COALESCE(at.FQty, 0)) DESC;

        -- Part 3: Third Insert Statement
        INSERT INTO lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, val1, val2, val3, val4)
        SELECT 'D' AS time_dims,
               (_test_date - INTERVAL '1 DAY') AS time_val,
               (_test_date - INTERVAL '2 DAY') AS begin_time,
               _test_date AS end_time,
               '角色' AS data_dims,
               a.id AS data_val,
               'sorting-daily-report' AS stat_code,
               'weight-by-waste-structure' AS group1,
               'LW' AS group2,
               ROUND(SUM(COALESCE(at.FQty, 0)), 2) AS val1,
               ROUND(SUM(COALESCE(at.FQty, 0)), 2) - COALESCE(r.val1, 0) AS val2,
               COALESCE(ROUND((ROUND(SUM(COALESCE(at.FQty, 0)), 2) - COALESCE(r.val1, 0)) / COALESCE(r.val1, 0), 2), 0) * 100 AS val3,
               RANK() OVER (ORDER BY SUM(COALESCE(at.FQty, 0)) DESC) AS val4
        FROM Trans_assist_table at
        JOIN Trans_main_table mt ON mt.FInterID = at.FinterID AND mt.FTranType = at.FTranType AND mt.FCancellation = '1' AND mt.FSaleStyle = '0' AND mt.FTranType = 'SOR' AND DATE_TRUNC('day', at.FDCTime) = (_test_date - INTERVAL '1 DAY')
        RIGHT JOIN lh_dw.data_statistics_results r ON r.data_val = mt.FEmpID AND at.value_type = 'unvaluable' AND r.time_dims = 'D' AND r.time_val = (_test_date - INTERVAL '2 DAY') AND r.data_dims = '角色' AND r.stat_code = 'sorting-daily-report' AND r.group1 = 'weight-by-waste-structure' AND r.group2 = 'LW'
		JOIN uct_admin a ON CAST(a.id AS TEXT) = r.data_val
		JOIN uct_auth_group_access ga ON ga.uid = a.id AND ga.group_id = 42
		GROUP BY a.id
		ORDER BY SUM(COALESCE(at.FQty, 0)) DESC;

    -- Part 4: Fourth Insert Statement
    INSERT INTO lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, val1, val2, val3, val4)
    SELECT 'D' AS time_dims,
           (_test_date - INTERVAL '1 DAY') AS time_val,
           (_test_date - INTERVAL '2 DAY') AS begin_time,
           _test_date AS end_time,
           '角色' AS data_dims,
           a.id AS data_val,
           'sorting-daily-report' AS stat_code,
           'weight-by-waste-sorting' AS group1,
           'sorting' AS group2,
           ROUND(SUM(COALESCE(at.FQty, 0)), 2) AS val1,
           ROUND(SUM(COALESCE(at.FQty, 0)), 2) - COALESCE(r.val1, 0) AS val2,
           COALESCE(ROUND((ROUND(SUM(COALESCE(at.FQty, 0)), 2) - COALESCE(r.val1, 0)) / COALESCE(r.val1, 0), 2), 0) * 100 AS val3,
           RANK() OVER (ORDER BY SUM(COALESCE(at.FQty, 0)) DESC) AS val4
    FROM Trans_assist_table at
    JOIN Trans_main_table mt ON mt.FInterID = at.FinterID AND mt.FTranType = at.FTranType AND mt.FCancellation = '1' AND mt.FSaleStyle = '0' AND mt.FTranType = 'SOR' AND DATE_TRUNC('day', at.FDCTime) = (_test_date - INTERVAL '1 DAY')
    RIGHT JOIN lh_dw.data_statistics_results r ON r.data_val = mt.FEmpID AND at.disposal_way = 'sorting' AND r.time_dims = 'D' AND r.time_val = (_test_date - INTERVAL '2 DAY') AND r.data_dims = '角色' AND r.stat_code = 'sorting-daily-report' AND r.group1 = 'weight-by-waste-sorting' AND r.group2 = 'sorting'
    JOIN uct_admin a ON CAST(a.id AS TEXT) = r.data_val
    JOIN uct_auth_group_access ga ON ga.uid = a.id AND ga.group_id = 42
    GROUP BY a.id
    ORDER BY SUM(COALESCE(at.FQty, 0)) DESC;

    -- Part 5: Fifth Insert Statement
    INSERT INTO lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, val1, val2, val3, val4)
    SELECT 'D' AS time_dims,
           (_test_date - INTERVAL '1 DAY') AS time_val,
           (_test_date - INTERVAL '2 DAY') AS begin_time,
           _test_date AS end_time,
           '角色' AS data_dims,
           a.id AS data_val,
           'sorting-daily-report' AS stat_code,
           'weight-by-waste-sorting' AS group1,
           'weigh' AS group2,
           ROUND(SUM(COALESCE(at.FQty, 0)), 2) AS val1,
           ROUND(SUM(COALESCE(at.FQty, 0)), 2) - COALESCE(r.val1, 0) AS val2,
           COALESCE(ROUND((ROUND(SUM(COALESCE(at.FQty, 0)), 2) - COALESCE(r.val1, 0)) / COALESCE(r.val1, 0), 2), 0) * 100 AS val3,
           RANK() OVER (ORDER BY SUM(COALESCE(at.FQty, 0)) DESC) AS val4
    FROM Trans_assist_table at
    JOIN Trans_main_table mt ON mt.FInterID = at.FinterID AND mt.FTranType = at.FTranType AND mt.FCancellation = '1' AND mt.FSaleStyle = '0' AND mt.FTranType = 'SOR' AND DATE_TRUNC('day', at.FDCTime) = (_test_date - INTERVAL '1 DAY')
    RIGHT JOIN lh_dw.data_statistics_results r ON r.data_val = mt.FEmpID AND at.disposal_way = 'weighing' AND r.time_dims = 'D' AND r.time_val = (_test_date - INTERVAL '2 DAY') AND r.data_dims = '角色' AND r.stat_code = 'sorting-daily-report' AND r.group1 = 'weight-by-waste-sorting' AND r.group2 = 'weigh'
    JOIN uct_admin a ON CAST(a.id AS TEXT) = r.data_val
    JOIN uct_auth_group_access ga ON ga.uid = a.id AND ga.group_id = 42
    GROUP BY a.id
    ORDER BY SUM(COALESCE(at.FQty, 0)) DESC;

    -- Part 6: Sixth Insert Statement
    INSERT INTO lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, val1, val2, val3)
    SELECT 'D' AS time_dims,
           (_test_date - INTERVAL '1 DAY') AS time_val,
           (_test_date - INTERVAL '2 DAY') AS begin_time,
           _test_date AS end_time,
           '角色' AS data_dims,
           a.id AS data_val,
           'sorting-daily-report' AS stat_code,
           'commission' AS group1,
           ROUND(SUM(COALESCE(mt.TalForth, 0)), 2) AS val1,
           ROUND(SUM(COALESCE(mt.TalForth, 0)), 2) - COALESCE(r.val1, 0) AS val2,
           COALESCE(ROUND((SUM(COALESCE(mt.TalForth, 0)) - COALESCE(r.val1, 0)) / COALESCE(r.val1, 0), 2), 0) * 100 AS val3
    FROM Trans_main_table mt
    RIGHT JOIN lh_dw.data_statistics_results r ON r.data_val = mt.FEmpID AND mt.FCancellation = '1' AND mt.FCorrent = '1' AND mt.FSaleStyle = '0' AND mt.FTranType = 'SOR' AND mt."Date" = (_test_date - INTERVAL '1 DAY')
    JOIN uct_admin a ON CAST(a.id AS TEXT) = r.data_val
    JOIN uct_auth_group_access ga ON ga.uid = a.id AND ga.group_id = 42
    GROUP BY a.id;

    -- Part 7: Seventh Insert
        INSERT INTO lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, val1, val2, val3, val4)
        SELECT 'D' AS time_dims,
               (_test_date - INTERVAL '1 DAY') AS time_val,
               (_test_date - INTERVAL '2 DAY') AS begin_time,
               _test_date AS end_time,
               '部门' AS data_dims,
               d.id AS data_val,
               'sorting-daily-report' AS stat_code,
               'weight' AS group1,
               'RW' AS group2,
               ROUND(SUM(COALESCE(at.FQty, 0)), 2) AS val1,
               ROUND(SUM(COALESCE(at.FQty, 0)), 2) - COALESCE(r.val1, 0) AS val2,
               COALESCE(ROUND((ROUND(SUM(COALESCE(at.FQty, 0)), 2) - COALESCE(r.val1, 0)) / COALESCE(r.val1, 0), 2), 0) * 100 AS val3,
               RANK() OVER (ORDER BY SUM(COALESCE(at.FQty, 0)) DESC) AS val4
        FROM Trans_assist_table at
        JOIN Trans_main_table mt ON mt.FInterID = at.FinterID AND mt.FTranType = at.FTranType AND mt.FCancellation = '1' AND mt.FSaleStyle = '0' AND mt.FTranType = 'SOR' AND DATE_TRUNC('day', at.FDCTime) = (_test_date - INTERVAL '1 DAY')
        RIGHT JOIN lh_dw.data_statistics_results r ON r.data_val = mt.FDeptID AND at.value_type = 'valuable' AND r.time_dims = 'D' AND r.time_val = (_test_date - INTERVAL '2 DAY') AND r.data_dims = '部门' AND r.stat_code = 'sorting-daily-report' AND r.group1 = 'weight' AND r.group2 = 'RW'
        JOIN department d ON CAST(d.id AS TEXT) = r.data_val
        JOIN department_relation dr ON dr.id = d.id AND dr.active = '1'
        JOIN uct_auth_group_access ga ON ga.uid = dr.pid AND ga.group_id = 42
        GROUP BY d.id
        ORDER BY SUM(COALESCE(at.FQty, 0)) DESC;

        -- Part 8: Eighth Insert Statement
        INSERT INTO lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, val1, val2, val3, val4)
        SELECT 'D' AS time_dims,
               (_test_date - INTERVAL '1 DAY') AS time_val,
               (_test_date - INTERVAL '2 DAY') AS begin_time,
               _test_date AS end_time,
               '部门' AS data_dims,
               d.id AS data_val,
               'sorting-daily-report' AS stat_code,
               'weight' AS group1,
               'LW' AS group2,
               ROUND(SUM(COALESCE(at.FQty, 0)), 2) AS val1,
               ROUND(SUM(COALESCE(at.FQty, 0)), 2) - COALESCE(r.val1, 0) AS val2,
               COALESCE(ROUND((ROUND(SUM(COALESCE(at.FQty, 0)), 2) - COALESCE(r.val1, 0)) / COALESCE(r.val1, 0), 2), 0) * 100 AS val3,
               RANK() OVER (ORDER BY SUM(COALESCE(at.FQty, 0)) DESC) AS val4
        FROM Trans_assist_table at
        JOIN Trans_main_table mt ON mt.FInterID = at.FinterID AND mt.FTranType = at.FTranType AND mt.FCancellation = '1' AND mt.FSaleStyle = '0' AND mt.FTranType = 'SOR' AND DATE_TRUNC('day', at.FDCTime) = (_test_date - INTERVAL '1 DAY')
        RIGHT JOIN lh_dw.data_statistics_results r ON r.data_val = mt.FDeptID AND at.value_type = 'valuable' AND r.time_dims = 'D' AND r.time_val = (_test_date - INTERVAL '2 DAY') AND r.data_dims = '部门' AND r.stat_code = 'sorting-daily-report' AND r.group1 = 'weight' AND r.group2 = 'LW'
        JOIN department d ON CAST(d.id AS TEXT) = r.data_val
        JOIN department_relation dr ON dr.id = d.id AND dr.active = '1'
        JOIN uct_auth_group_access ga ON ga.uid = dr.pid AND ga.group_id = 42
        GROUP BY d.id
        ORDER BY SUM(COALESCE(at.FQty, 0)) DESC;

        -- Part 9: Ninth Insert Statement
        INSERT INTO lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, val1, val2, val3, val4)
        SELECT 'D' AS time_dims,
               (_test_date - INTERVAL '1 DAY') AS time_val,
               (_test_date - INTERVAL '2 DAY') AS begin_time,
               _test_date AS end_time,
               '部门' AS data_dims,
               d.id AS data_val,
               'sorting-daily-report' AS stat_code,
               'commission' AS group1,
               'weigh' AS group2,
               ROUND(SUM(COALESCE(mt.TalForth, 0)), 2) AS val1,
               ROUND(SUM(COALESCE(mt.TalForth, 0)), 2) - COALESCE(r.val1, 0) AS val2,
               COALESCE(ROUND((SUM(COALESCE(mt.TalForth, 0)) - COALESCE(r.val1, 0)) / COALESCE(r.val1, 0), 2), 0) * 100 AS val3,
               RANK() OVER (ORDER BY SUM(COALESCE(mt.TalForth, 0)) DESC) AS val4
        FROM Trans_main_table mt
        RIGHT JOIN lh_dw.data_statistics_results r ON r.data_val = mt.FDeptID AND mt.FCancellation = '1' AND mt.FCorrent = '1' AND mt.FSaleStyle = '0' AND mt.FTranType = 'SOR' AND mt."Date" = (_test_date - INTERVAL '1 DAY')
        JOIN department d ON CAST(d.id AS TEXT) = r.data_val
        JOIN department_relation dr ON dr.id = d.id AND dr.active = '1'
        JOIN uct_auth_group_access ga ON ga.uid = dr.pid AND ga.group_id = 42
        GROUP BY d.id;

        _test_date := _test_date + INTERVAL '1 DAY';
    END LOOP;
END;
$$;



CREATE OR REPLACE PROCEDURE uctoo_lvhuan.sorting_end_and_edit(
    INOUT p_line_id varchar(20),
    INOUT p_po varchar(20),
    INOUT o_rv integer,
    INOUT o_err varchar(200)
)
LANGUAGE plpgsql
AS
$$
DECLARE
    v_id            integer;
    v_leader        integer;
    v_priority      integer;
    v_num           integer;
    v_number        integer;
    v_pur_id        integer;
    v_sub_id        integer;
    v_check_id      integer;
    v_old_weight    float;
    v_old_money     float;
    v_now_weight    float;
    v_now_money     float;
    v_total_weight  float;
    v_total_money   float;
    v_sort_height   float;
    v_sort_low      float;
    v_weight_height float;
    v_weight_low    float;
    v_sort_cargo_price float;
    v_weight_cargo_price float;
    v_sort_labor_price float;
    v_weight_labor_price float;
    v_commission    float;
    v_artificial    float;
    errno           int;
BEGIN
    -- Exception Handler
    EXCEPTION
        WHEN others THEN
            ROLLBACK;
            GET STACKED DIAGNOSTICS o_err = MESSAGE_TEXT;
            o_rv := 400;
            RETURN;
    -- Main Procedure
    BEGIN
        SELECT id, leader, priority INTO v_id, v_leader, v_priority
        FROM uct_sorting_jobs
        WHERE (status = 'startup' OR status = 'waiting')
          AND line_id = p_line_id
          AND purchase_order_no = p_po
        LIMIT 1;

        IF v_id IS NULL THEN
            o_rv := 400;
            o_err := '获取任务表id失败.';
            RETURN;
        END IF;

        SELECT COUNT(1) INTO v_sub_id
        FROM uct_sorting_commit
        WHERE line_id = p_line_id
          AND purchase_order_no = p_po
          AND process = 'pending';

        IF v_sub_id > 0 THEN
            o_rv := 400;
            o_err := '请对这个批次的所有数据进行确认后，再点击批次完成.';
            RETURN;
        END IF;

        SELECT IFNULL(MAX(revision), 0) + 1 INTO v_num
        FROM uct_sorting_job_logs
        WHERE line_id = p_line_id
          AND purchase_order_no = p_po;

        IF v_num IS NULL THEN
            o_rv := 400;
            o_err := '获取最大的版本号失败.';
            RETURN;
        END IF;

        SELECT id, IFNULL(storage_weight, 0), IFNULL(storage_cargo_price, 0) INTO v_pur_id, v_old_weight, v_old_money
        FROM uct_waste_purchase
        WHERE order_id = p_po;

        IF v_pur_id IS NULL THEN
            o_rv := 400;
            o_err := '获取订单表的自增id失败.';
            RETURN;
        END IF;

        SELECT COUNT(1), IFNULL(SUM(net_weight * presell_price), 0), IFNULL(SUM(net_weight), 0)
        INTO v_check_id, v_now_money, v_now_weight
        FROM uct_sorting_commit
        WHERE sub_time = 0
          AND process = 'passed'
          AND line_id = p_line_id
          AND purchase_order_no = p_po;

        v_total_weight := v_old_weight + v_now_weight;
        v_total_money := v_old_money + v_now_money;

        SELECT COUNT(id) INTO v_number
        FROM uct_sorting_jobs
        WHERE priority > v_priority
          AND line_id = p_line_id;

        SELECT IFNULL(SUM(a.net_weight), 0) INTO v_sort_height
        FROM uct_sorting_commit AS a
        LEFT JOIN uct_waste_cate AS b ON a.cate_id = b.id
        WHERE a.process = 'passed'
          AND a.disposal_way = 'sorting'
          AND a.sub_time = 0
          AND b.value_type = 'valuable'
          AND a.purchase_order_no = p_po
          AND a.line_id = p_line_id;

        SELECT IFNULL(SUM(a.net_weight), 0) INTO v_sort_low
        FROM uct_sorting_commit AS a
        LEFT JOIN uct_waste_cate AS b ON a.cate_id = b.id
        WHERE a.process = 'passed'
          AND a.disposal_way = 'sorting'
          AND a.sub_time = 0
          AND b.value_type = 'unvaluable'
          AND a.purchase_order_no = p_po
          AND a.line_id = p_line_id;

        SELECT IFNULL(SUM(a.net_weight), 0) INTO v_weight_height
        FROM uct_sorting_commit AS a
        LEFT JOIN uct_waste_cate AS b ON a.cate_id = b.id
        WHERE a.process = 'passed'
          AND a.disposal_way = 'weighing'
          AND a.sub_time = 0
          AND b.value_type = 'valuable'
          AND a.purchase_order_no = p_po
          AND a.line_id = p_line_id;

        SELECT IFNULL(SUM(a.net_weight), 0) INTO v_weight_low
        FROM uct_sorting_commit AS a
        LEFT JOIN uct_waste_cate AS b ON a.cate_id = b.id
        WHERE a.process = 'passed'
          AND a.disposal_way = 'weighing'
          AND a.sub_time = 0
          AND b.value_type = 'unvaluable'
          AND a.purchase_order_no = p_po
          AND a.line_id = p_line_id;

        SELECT sorting_unit_cargo_price, weigh_unit_cargo_price, sorting_unit_labor_price, weigh_unit_labor_price
        INTO v_sort_cargo_price, v_weight_cargo_price, v_sort_labor_price, v_weight_labor_price
        FROM uct_waste_purchase AS a
        LEFT JOIN uct_branch AS b ON a.branch_id = b.setting_key
        WHERE a.order_id = p_po;

        v_commission := (v_sort_height * v_sort_cargo_price + v_weight_height * v_weight_cargo_price) / 1000;
        v_artificial := ((v_sort_height + v_sort_low) * v_sort_labor_price + (v_weight_height + v_weight_low) * v_weight_labor_price) / 1000;

        BEGIN
            -- Transaction Block
            START TRANSACTION;
            SAVEPOINT sp;

            -- Exception Handler for rollback in case of errors
            EXCEPTION
                WHEN others THEN
                    ROLLBACK;
                    GET STACKED DIAGNOSTICS o_err = MESSAGE_TEXT;
                    o_rv := 400;
                    RETURN;
        END;

        -- Perform the required updates and inserts
        UPDATE uct_sorting_jobs
        SET status = 'finish', priority = 0
        WHERE id = v_id;

        IF v_priority > 0 AND v_number > 0 THEN
            UPDATE uct_sorting_jobs
            SET priority = priority - 1
            WHERE priority > v_priority;
        END IF;

        INSERT INTO uct_sorting_job_logs
        (line_id, purchase_order_no, status, revision, leader)
        VALUES (p_line_id, p_po, 'finish', v_num, v_leader);

        UPDATE uct_bas_station
        SET status = 'stand-by'
        WHERE status = 'working' AND line_id = p_line_id;

        UPDATE uct_waste_purchase
        SET storage_weight = v_total_weight,
            storage_cargo_price = v_total_money,
            sorting_valuable_weight = IFNULL(sorting_valuable_weight, 0) + v_sort_height,
            sorting_unvaluable_weight = IFNULL(sorting_unvaluable_weight, 0) + v_sort_low,
            weigh_valuable_weight = IFNULL(weigh_valuable_weight, 0) + v_weight_height,
            weigh_unvaluable_weight = IFNULL(weigh_unvaluable_weight, 0) + v_weight_low,
            total_cargo_price = IFNULL(total_cargo_price, 0) + v_commission,
            total_labor_price = IFNULL(total_labor_price, 0) + v_artificial
        WHERE id = v_pur_id;

        INSERT INTO uct_waste_storage_sort
        (purchase_id, cargo_sort, total_weight, net_weight, rough_weight,
         presell_price, sort_time, createtime, disposal_way, value_type)
        SELECT v_pur_id,
               a.cate_id,
               SUM(a.net_weight) as weight,
               SUM(a.net_weight) as weight,
               0,
               MIN(a.presell_price),
               EXTRACT(EPOCH FROM MAX(a.end_time)),
               EXTRACT(EPOCH FROM NOW()),
               a.disposal_way,
               b.value_type
        FROM uct_sorting_commit AS a
        LEFT JOIN uct_waste_cate AS b ON a.cate_id = b.id
        WHERE a.process = 'passed'
          AND a.sub_time = 0
          AND a.line_id = p_line_id
          AND a.purchase_order_no = p_po
        GROUP BY a.cate_id;

        UPDATE uct_sorting_commit
        SET sub_time = EXTRACT(EPOCH FROM NOW())
        WHERE sub_time = 0
          AND purchase_order_no = p_po
          AND line_id = p_line_id;

        COMMIT;

        o_rv := 200;
        o_err := '批次完成处理成功.';
        RETURN;
    END;
END;
$$;


CREATE OR REPLACE PROCEDURE uctoo_lvhuan.sorting_end_and_edit_copy(
    IN p_line_id VARCHAR(20),
    IN p_po VARCHAR(20),
    INOUT p_o_rv INTEGER,
    INOUT p_o_err VARCHAR(200)
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_id INTEGER;
    v_leader INTEGER;
    v_num INTEGER;
    v_pur_id INTEGER;
    v_sub_id INTEGER;
    v_check_id INTEGER;
    v_total_weight FLOAT;
    v_total_money FLOAT;
    errno INT;
BEGIN
    -- Exception Handler
    EXCEPTION
        WHEN OTHERS THEN
            GET STACKED DIAGNOSTICS errno = RETURNED_SQLSTATE;
            p_o_rv := 400;
            p_o_err := '批次完成处理失败. Error Code: ' || errno;
            RETURN;
    -- Main Procedure
    BEGIN
        SELECT id, leader INTO v_id, v_leader
        FROM uct_sorting_jobs
        WHERE status = 'startup'
          AND line_id = p_line_id
          AND purchase_order_no = p_po
        LIMIT 1;

        IF v_id IS NULL THEN
            p_o_rv := 400;
            p_o_err := '获取任务表id失败.';
            RETURN;
        END IF;

        SELECT COUNT(1) INTO v_sub_id
        FROM uct_sorting_commit
        WHERE line_id = p_line_id
          AND purchase_order_no = p_po
          AND process = 'pending';

        IF v_sub_id > 0 THEN
            p_o_rv := 400;
            p_o_err := '请对这个批次的所有数据进行确认后，再点击批次完成.';
            RETURN;
        END IF;

        SELECT COALESCE(MAX(revision), 0) + 1 INTO v_num
        FROM uct_sorting_job_logs
        WHERE line_id = p_line_id
          AND purchase_order_no = p_po;

        IF v_num IS NULL THEN
            p_o_rv := 400;
            p_o_err := '获取最大的版本号失败.';
            RETURN;
        END IF;

        SELECT id INTO v_pur_id
        FROM uct_waste_purchase
        WHERE order_id = p_po;

        IF v_pur_id IS NULL THEN
            p_o_rv := 400;
            p_o_err := '获取订单表的自增id失败.';
            RETURN;
        END IF;

        SELECT COUNT(1), SUM(net_weight * presell_price), SUM(net_weight)
        INTO v_check_id, v_total_money, v_total_weight
        FROM uct_sorting_commit
        WHERE process = 'passed'
          AND line_id = p_line_id
          AND purchase_order_no = p_po;

        IF v_check_id < 1 THEN
            p_o_rv := 400;
            p_o_err := '获取总重量或总金额失败.';
            RETURN;
        END IF;

        -- Transaction Block
        BEGIN
            START TRANSACTION;

            UPDATE uct_sorting_jobs SET status = 'finish' WHERE id = v_id;

            INSERT INTO uct_sorting_job_logs (line_id, purchase_order_no, status, revision, leader)
            VALUES (p_line_id, p_po, 'finish', v_num, v_leader);

            UPDATE uct_bas_station SET status = 'stand-by' WHERE status = 'working' AND line_id = p_line_id;

            UPDATE uct_waste_purchase SET storage_weight = v_total_weight, storage_cargo_price = v_total_money WHERE id = v_pur_id;

            INSERT INTO uct_waste_storage_sort (purchase_id, cargo_sort, net_weight, total_weight, rough_weight, presell_price, sort_time, createtime)
            SELECT v_pur_id, cate_id, SUM(net_weight) as weight, SUM(net_weight) as weight, 0, MIN(presell_price),
                   EXTRACT(EPOCH FROM MAX(end_time)), EXTRACT(EPOCH FROM NOW())
            FROM uct_sorting_commit
            WHERE process = 'passed' AND line_id = p_line_id AND purchase_order_no = p_po
            GROUP BY cate_id;

            UPDATE uct_sorting_commit SET sub_time = EXTRACT(EPOCH FROM NOW())
            WHERE sub_time = 0 AND purchase_order_no = p_po AND line_id = p_line_id;

            COMMIT;

            p_o_rv := 200;
            p_o_err := '批次完成处理成功.';
        EXCEPTION
            WHEN OTHERS THEN
                ROLLBACK;
                GET STACKED DIAGNOSTICS errno = RETURNED_SQLSTATE;
                p_o_rv := 400;
                p_o_err := '批次完成处理失败. Error Code: ' || errno;
        END;

        RETURN;
    END;
END;
$$;


CREATE OR REPLACE PROCEDURE uctoo_lvhuan.sorting_end_and_edit_once(
    IN p_line_id varchar(20), 
    IN p_po varchar(20), 
    INOUT o_rv integer, 
    INOUT o_err varchar(200)
) 
LANGUAGE plpgsql
AS $$
DECLARE
    v_id integer;
    v_leader integer;
    v_priority integer;
    v_num integer;
    v_number integer;
    v_pur_id integer;
    v_sub_id integer;
    v_check_id integer;
    v_sum_id integer;
    v_old_weight float;
    v_old_money float;
    v_now_weight float;
    v_now_money float;
    v_total_weight float;
    v_total_money float;
    v_sort_height float;
    v_sort_low float;
    v_weight_height float;
    v_weight_low float;
    v_sort_cargo_price float;
    v_weight_cargo_price float;
    v_sort_labor_price float;
    v_weight_labor_price float;
    v_commission float;
    v_artificial float;
    errno int;
BEGIN
    v_id := 0;
    v_leader := 0;
    v_priority := 0;
    v_num := 0;
    v_number := 0;
    v_pur_id := 0;
    v_sub_id := 0;
    v_check_id := 0;
    v_sum_id := 0;
    v_old_weight := 0;
    v_old_money := 0;
    v_now_weight := 0;
    v_now_money := 0;
    v_total_weight := 0;
    v_total_money := 0;
    v_sort_height := 0;
    v_sort_low := 0;
    v_weight_height := 0;
    v_weight_low := 0;
    v_sort_cargo_price := 0;
    v_weight_cargo_price := 0;
    v_sort_labor_price := 0;
    v_weight_labor_price := 0;
    v_commission := 0;
    v_artificial := 0;
    errno := 0;

    BEGIN
        SELECT id, leader, priority INTO v_id, v_leader, v_priority
        FROM uct_sorting_jobs
        WHERE line_id = p_line_id AND purchase_order_no = p_po
        LIMIT 1;

        IF v_id IS NULL THEN
            o_rv := 400;
            o_err := '获取任务表id失败.';
            RETURN;
        END IF;

        SELECT COUNT(1) INTO v_sum_id
        FROM uct_sorting_commit
        WHERE sub_time = 0 AND line_id = p_line_id AND purchase_order_no = p_po;

        IF v_sum_id < 1 THEN
            o_rv := 400;
            o_err := '没有可以入库的数据.';
            RETURN;
        END IF;

        SELECT COUNT(1) INTO v_sub_id
        FROM uct_sorting_commit
        WHERE sub_time = 0 AND line_id = p_line_id AND purchase_order_no = p_po AND process = 'pending';

        IF v_sub_id > 0 THEN
            o_rv := 400;
            o_err := '请对这个批次的所有数据进行确认后，再点击单次入库.';
            RETURN;
        END IF;

        SELECT COALESCE(MAX(revision), 0) + 1 INTO v_num
        FROM uct_sorting_job_logs
        WHERE line_id = p_line_id AND purchase_order_no = p_po;

        IF v_num IS NULL THEN
            o_rv := 400;
            o_err := '获取最大的版本号失败.';
            RETURN;
        END IF;

        SELECT id, COALESCE(storage_weight, 0), COALESCE(storage_cargo_price, 0) INTO v_pur_id, v_old_weight, v_old_money
        FROM uct_waste_purchase
        WHERE order_id = p_po;

        IF v_pur_id IS NULL THEN
            o_rv := 400;
            o_err := '获取订单表的自增id失败.';
            RETURN;
        END IF;

        SELECT COUNT(1), COALESCE(SUM(net_weight * presell_price), 0), COALESCE(SUM(net_weight), 0)
        INTO v_check_id, v_now_money, v_now_weight
        FROM uct_sorting_commit
        WHERE sub_time = 0 AND process = 'passed' AND line_id = p_line_id AND purchase_order_no = p_po;

        IF v_check_id < 1 THEN
            o_rv := 400;
            o_err := '获取单次总重量或总金额失败.';
            RETURN;
        END IF;

        v_total_weight := v_old_weight + v_now_weight;
        v_total_money := v_old_money + v_now_money;

        SELECT COALESCE(SUM(a.net_weight), 0) INTO v_sort_height
        FROM uct_sorting_commit AS a
        LEFT JOIN uct_waste_cate AS b ON a.cate_id = b.id
        WHERE a.process = 'passed'
        AND a.disposal_way = 'sorting'
        AND a.sub_time = 0
        AND b.value_type = 'valuable'
        AND a.purchase_order_no = p_po
        AND a.line_id = p_line_id;

        SELECT COALESCE(SUM(a.net_weight), 0) INTO v_sort_low
        FROM uct_sorting_commit AS a
        LEFT JOIN uct_waste_cate AS b ON a.cate_id = b.id
        WHERE a.process = 'passed'
        AND a.disposal_way = 'sorting'
        AND a.sub_time = 0
        AND b.value_type = 'unvaluable'
        AND a.purchase_order_no = p_po
        AND a.line_id = p_line_id;

        SELECT COALESCE(SUM(a.net_weight), 0) INTO v_weight_height
        FROM uct_sorting_commit AS a
        LEFT JOIN uct_waste_cate AS b ON a.cate_id = b.id
        WHERE a.process = 'passed'
        AND a.disposal_way = 'weighing'
        AND a.sub_time = 0
        AND b.value_type = 'valuable'
        AND a.purchase_order_no = p_po
        AND a.line_id = p_line_id;

        SELECT COALESCE(SUM(a.net_weight), 0) INTO v_weight_low
        FROM uct_sorting_commit AS a
        LEFT JOIN uct_waste_cate AS b ON a.cate_id = b.id
        WHERE a.process = 'passed'
        AND a.disposal_way = 'weighing'
        AND a.sub_time = 0
        AND b.value_type = 'unvaluable'
        AND a.purchase_order_no = p_po
        AND a.line_id = p_line_id;

        SELECT sorting_unit_cargo_price, weigh_unit_cargo_price, sorting_unit_labor_price, weigh_unit_labor_price
        INTO v_sort_cargo_price, v_weight_cargo_price, v_sort_labor_price, v_weight_labor_price
        FROM uct_waste_purchase AS a
        LEFT JOIN uct_branch AS b ON a.branch_id = b.setting_key
        WHERE a.order_id = p_po;

        v_commission := (v_sort_height * v_sort_cargo_price + v_weight_height * v_weight_cargo_price) / 1000;
        v_artificial := ((v_sort_height + v_sort_low) * v_sort_labor_price + (v_weight_height + v_weight_low) * v_weight_labor_price) / 1000;
        END;
		
        BEGIN
            UPDATE uct_waste_purchase SET
                storage_weight = v_total_weight,
                storage_cargo_price = v_total_money,
                sorting_valuable_weight = COALESCE((sorting_valuable_weight), 0) + v_sort_height,
                sorting_unvaluable_weight = COALESCE((sorting_unvaluable_weight), 0) + v_sort_low,
                weigh_valuable_weight = COALESCE((weigh_valuable_weight), 0) + v_weight_height,
                weigh_unvaluable_weight = COALESCE((weigh_unvaluable_weight), 0) + v_weight_low,
                total_cargo_price = COALESCE((total_cargo_price), 0) + v_commission,
                total_labor_price = COALESCE((total_labor_price), 0) + v_artificial
            WHERE id = v_pur_id;
            EXCEPTION WHEN others THEN
                o_rv := 400;
                o_err := '更新订单表失败.';
                ROLLBACK;
                RETURN;
        END;

        BEGIN
            INSERT INTO uct_waste_storage_sort (purchase_id, cargo_sort, total_weight, net_weight, rough_weight, presell_price, sort_time, createtime, disposal_way, value_type)
            SELECT v_pur_id, a.cate_id, SUM(a.net_weight) AS weight, SUM(a.net_weight) AS weight, 0, MIN(a.presell_price), EXTRACT(EPOCH FROM MAX(a.end_time)), EXTRACT(EPOCH FROM NOW()), a.disposal_way, b.value_type
            FROM uct_sorting_commit AS a
            LEFT JOIN uct_waste_cate AS b ON a.cate_id = b.id
            WHERE a.process = 'passed' AND a.sub_time = 0 AND a.line_id = p_line_id AND a.purchase_order_no = p_po
            GROUP BY a.cate_id;
            EXCEPTION WHEN others THEN
                o_rv := 400;
                o_err := '插入入库表失败.';
                ROLLBACK;
                RETURN;
        END;

        BEGIN
            UPDATE uct_sorting_commit
            SET sub_time = EXTRACT(EPOCH FROM NOW())
            WHERE sub_time = 0 AND purchase_order_no = p_po AND line_id = p_line_id;
            EXCEPTION WHEN others THEN
                o_rv := 400;
                o_err := '更新确认表失败.';
                ROLLBACK;
                RETURN;
        END;
		
        o_rv := 200;
        o_err := '单次入库处理成功.';

    EXCEPTION
        WHEN others THEN
            o_rv := 400;
            o_err := '批次完成处理失败.';
            RETURN;
END;
$$;


CREATE OR REPLACE PROCEDURE uctoo_lvhuan.star_history(IN start_time date, IN end_time date) 
LANGUAGE plpgsql
AS $$
DECLARE
    nowdate date;
BEGIN
    nowdate := start_time;
    LOOP
        EXIT WHEN nowdate > end_time;

        INSERT INTO lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, val1, val2)
        SELECT 
            'M' as time_dims, 
            to_char(nowdate, 'YYYY-MM') as time_val, 
            (last_day(nowdate - interval '2 months') + interval '1 day') as begin_time,
            (last_day(nowdate - interval '1 month')) || ' 23:59:59' as end_time,
            '客户' as data_dims,
            wc.id as data_val,
            'star-monthly-report' as stat_code,
            'cost_change' as group1,
            'sort_fee' as group2,
            round(coalesce(sum(ft.FFeeAmount), 0), 2) as val1,
            round(coalesce(sum(ft.FFeeAmount), 0) - coalesce(r.val1, 0), 2) as val2 
        FROM Trans_main_table mt 
        JOIN Trans_main_table mt2 ON mt.FBillNo = mt2.FBillNo 
            AND mt.FTranType = 'PUR' 
            AND (mt2.FTranType in ('SOR', 'SEL') AND mt2.FSaleStyle in (0, 1, 3)) 
            AND mt2.FCancellation = 1 
            AND mt2.FCorrent 
            AND mt2."Date" BETWEEN (last_day(nowdate - interval '2 months') + interval '1 day') AND last_day(nowdate - interval '1 month')
        JOIN Trans_fee_table ft ON ft.FinterID = mt2.FInterID 
            AND ft.FTranType = mt2.FTranType 
            AND ft.FFeeID = '资源池分拣人工'
        RIGHT JOIN uct_waste_customer wc ON wc.id = mt.FSupplyID
        LEFT JOIN lh_dw.data_statistics_results r ON r.data_val = mt.FSupplyID 
            AND r.time_dims = 'M' 
            AND r.time_val = to_char(nowdate - interval '1 month', 'YYYY-MM') 
            AND r.data_dims = '客户' 
            AND r.data_val = wc.id 
            AND r.stat_code = 'star-monthly-report' 
            AND r.group1 = 'cost_change' 
            AND r.group2 = 'sort_fee'
        WHERE wc.customer_type = 'up'
        GROUP BY wc.id;  

        nowdate := (nowdate + interval '1 month');
    END LOOP;
END;
$$;


CREATE OR REPLACE PROCEDURE uctoo_lvhuan.test_sel_add(IN id int) 
LANGUAGE plpgsql
AS $$
DECLARE
    move INT := 0;
BEGIN
    SELECT is_move INTO move FROM uct_waste_sell AS s WHERE s.id = id;
    IF move = 1 THEN
        SELECT move;
    END IF;
END;
$$;

CREATE OR REPLACE PROCEDURE uctoo_lvhuan.Trans_assist_pur(IN id int) 
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM Trans_assist_table WHERE FTranType = 'PUR' AND FInterID = id;
    INSERT INTO Trans_assist_table
        SELECT
            uct_waste_purchase_cargo.purchase_id AS FInterID,
            'PUR' AS FTranType,
            uct_waste_purchase_cargo.id AS FEntryID,
            uct_waste_purchase_cargo.cate_id AS FItemID,
            '1' AS FUnitID,
            uct_waste_purchase_cargo.net_weight AS FQty,
            uct_waste_purchase_cargo.unit_price AS FPrice,
            round(uct_waste_purchase_cargo.total_price, 2) AS FAmount,
            'sorting' AS disposal_way,
            uct_waste_cate.value_type AS value_type,
            '' AS FbasePrice,
            '' AS FbaseAmount,
            '' AS Ftaxrate,
            '' AS Fbasetax,
            '' AS Fbasetaxamount,
            '' AS FPriceRef,
            to_char(to_timestamp(uct_waste_purchase_cargo.createtime), 'YYYY-MM-DD HH24:MI:SS') AS FDCTime,
            '' AS FSourceInterID,
            '' AS FSourceTranType,
            NULL AS red_ink_time,
            0 AS is_hedge,
            0
        FROM uct_waste_purchase_cargo
        JOIN uct_waste_cate ON uct_waste_cate.id = uct_waste_purchase_cargo.cate_id
        WHERE uct_waste_purchase_cargo.purchase_id = id;
END;
$$;

CREATE OR REPLACE PROCEDURE uctoo_lvhuan.Trans_assist_sel(IN id int) 
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM Trans_assist_table WHERE FTranType = 'SEL' AND FInterID = id;
    INSERT INTO Trans_assist_table
        SELECT
            uct_waste_sell_cargo.sell_id AS FInterID,
            'SEL' AS FTranType,
            uct_waste_sell_cargo.id AS FEntryID,
            uct_waste_sell_cargo.cate_id AS FItemID,
            '1' AS FUnitID,
            uct_waste_sell_cargo.net_weight AS FQty,
            uct_waste_sell_cargo.unit_price AS FPrice,
            round(uct_waste_sell_cargo.unit_price * uct_waste_sell_cargo.net_weight, 2) AS FAmount,
            'sorting' AS disposal_way,
            'valuable' AS value_type,
            '' AS FbasePrice,
            '' AS FbaseAmount,
            '' AS Ftaxrate,
            '' AS Fbasetax,
            '' AS Fbasetaxamount,
            '' AS FPriceRef,
            to_char(to_timestamp(uct_waste_sell_cargo.updatetime), 'YYYY-MM-DD HH24:MI:SS') AS FDCTime,
            CASE WHEN uct_waste_sell.purchase_id > 0 THEN uct_waste_sell.purchase_id ELSE '' END AS FSourceInterID,
            CASE WHEN uct_waste_sell.purchase_id > 0 THEN 'PUR' ELSE '' END AS FSourceTranType,
            NULL AS red_ink_time,
            0 AS is_hedge,
            0
        FROM uct_waste_sell_cargo
        JOIN uct_waste_sell ON uct_waste_sell_cargo.sell_id = uct_waste_sell.id
        WHERE uct_waste_sell.id = id;
END;
$$;

CREATE OR REPLACE PROCEDURE uctoo_lvhuan.Trans_assist_sor(IN id int) 
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM Trans_assist_table WHERE FTranType = 'SOR' AND FInterID = id;
    INSERT INTO Trans_assist_table
        SELECT
            uct_waste_storage_sort.purchase_id AS FInterID,
            'SOR' AS FTranType,
            uct_waste_storage_sort.id AS FEntryID,
            uct_waste_storage_sort.cargo_sort AS FItemID,
            '1' AS FUnitID,
            uct_waste_storage_sort.net_weight AS FQty,
            uct_waste_storage_sort.presell_price AS FPrice,
            round(uct_waste_storage_sort.presell_price * uct_waste_storage_sort.net_weight, 2) AS FAmount,
            uct_waste_storage_sort.disposal_way AS disposal_way,
            uct_waste_storage_sort.value_type AS value_type,
            '' AS FbasePrice,
            '' AS FbaseAmount,
            '' AS Ftaxrate,
            '' AS Fbasetax,
            '' AS Fbasetaxamount,
            '' AS FPriceRef,
            to_char(to_timestamp(
                CASE 
                    WHEN uct_waste_storage_sort.sort_time > uct_waste_storage_sort.createtime THEN uct_waste_storage_sort.sort_time
                    ELSE uct_waste_storage_sort.createtime
                END
            ), 'YYYY-MM-DD HH24:MI:SS') AS FDCTime,
            uct_waste_storage_sort.purchase_id AS FSourceInterID,
            'PUR' AS FSourceTranType,
            NULL AS red_ink_time,
            0 AS is_hedge,
            0
        FROM uct_waste_storage_sort
        WHERE uct_waste_storage_sort.purchase_id = id;
END;
$$;

CREATE OR REPLACE PROCEDURE uctoo_lvhuan.Trans_fee_pc(IN id int) 
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM Trans_fee_table WHERE FTranType = 'PUR' AND Ffeesence = 'PC' AND FInterID = id;
    INSERT INTO Trans_fee_table
        SELECT
            uct_waste_purchase_expense.purchase_id AS FInterID,
            'PUR' AS FTranType,
            'PC' AS Ffeesence,
            uct_waste_purchase_expense.id AS FEntryID,
            uct_waste_purchase_expense.usage AS FFeeID,
            uct_waste_purchase_expense.type AS FFeeType,
            uct_waste_purchase_expense.receiver AS FFeePerson,
            uct_waste_purchase_expense.remark AS FFeeExplain,
            uct_waste_purchase_expense.price AS FFeeAmount,
            '' AS FFeebaseAmount,
            '' AS Ftaxrate,
            '' AS Fbasetax,
            '' AS Fbasetaxamount,
            '' AS FPriceRef,
            to_char(to_timestamp(uct_waste_purchase_expense.createtime), 'YYYY-MM-DD HH24:MI:SS') AS FFeetime,
            NULL AS red_ink_time,
            0 AS is_hedge,
            0
        FROM uct_waste_purchase_expense
        WHERE uct_waste_purchase_expense.purchase_id = id;
END;
$$;

CREATE OR REPLACE PROCEDURE uctoo_lvhuan.Trans_fee_pur(IN id int) 
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT
        uct_waste_purchase_cargo.purchase_id AS FInterID,
        'PUR' AS FTranType,
        uct_waste_purchase_cargo.id AS FEntryID,
        uct_waste_purchase_cargo.cate_id AS FItemID,
        '1' AS FUnitID,
        uct_waste_purchase_cargo.net_weight AS FQty,
        uct_waste_purchase_cargo.unit_price AS FPrice,
        round(uct_waste_purchase_cargo.total_price, 2) AS FAmount,
        '' AS FbasePrice,
        '' AS FbaseAmount,
        '' AS Ftaxrate,
        '' AS Fbasetax,
        '' AS Fbasetaxamount,
        '' AS FPriceRef,
        to_char(to_timestamp(uct_waste_purchase_cargo.createtime), 'YYYY-MM-DD HH24:MI:SS') AS FDCTime,
        '' AS FSourceInterID,
        '' AS FSourceTranType
    FROM uct_waste_purchase_cargo
    WHERE uct_waste_purchase_cargo.purchase_id = id;
END;
$$;

CREATE OR REPLACE PROCEDURE uctoo_lvhuan.Trans_fee_rf(IN id int) 
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM Trans_fee_table WHERE FTranType = 'PUR' AND Ffeesence = 'RF' AND FInterID = id;
    INSERT INTO Trans_fee_table
        SELECT
            uct_waste_storage_return_fee.purchase_id AS FInterID,
            'PUR' AS FTranType,
            'RF' AS Ffeesence,
            uct_waste_storage_return_fee.id AS FEntryID,
            uct_waste_storage_return_fee.usage AS FFeeID,
            'out' AS FFeeType,
            uct_waste_storage_return_fee.receiver AS FFeePerson,
            uct_waste_storage_return_fee.remark AS FFeeExplain,
            uct_waste_storage_return_fee.price AS FFeeAmount,
            '' AS FFeebaseAmount,
            '' AS Ftaxrate,
            '' AS Fbasetax,
            '' AS Fbasetaxamount,
            '' AS FPriceRef,
            to_char(to_timestamp(uct_waste_storage_return_fee.createtime), 'YYYY-MM-DD HH24:MI:SS') AS FFeetime,
            NULL AS red_ink_time,
            0 AS is_hedge,
            0
        FROM uct_waste_storage_return_fee
        WHERE uct_waste_storage_return_fee.purchase_id = id;
END;
$$;


CREATE OR REPLACE PROCEDURE uctoo_lvhuan.Trans_fee_sel(IN id int) 
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT
        uct_waste_sell_cargo.sell_id AS FInterID,
        'SEL' AS FTranType,
        uct_waste_sell_cargo.id AS FEntryID,
        uct_waste_sell_cargo.cate_id AS FItemID,
        '1' AS FUnitID,
        CASE WHEN uct_waste_sell.purchase_id > 0 THEN uct_waste_sell_cargo.plan_sell_weight ELSE uct_waste_sell_cargo.net_weight END AS FQty,
        uct_waste_sell_cargo.unit_price AS FPrice,
        round(uct_waste_sell_cargo.unit_price * CASE WHEN uct_waste_sell.purchase_id > 0 THEN uct_waste_sell_cargo.plan_sell_weight ELSE uct_waste_sell_cargo.net_weight END, 2) AS FAmount,
        '' AS FbasePrice,
        '' AS FbaseAmount,
        '' AS Ftaxrate,
        '' AS Fbasetax,
        '' AS Fbasetaxamount,
        '' AS FPriceRef,
        to_char(to_timestamp(uct_waste_sell_cargo.createtime), 'YYYY-MM-DD HH24:MI:SS') AS FDCTime,
        CASE WHEN uct_waste_sell.purchase_id > 0 THEN uct_waste_sell.purchase_id ELSE '' END AS FSourceInterID,
        CASE WHEN uct_waste_sell.purchase_id > 0 THEN 'PUR' ELSE '' END AS FSourceTranType
    FROM uct_waste_sell_cargo
    JOIN uct_waste_sell ON uct_waste_sell_cargo.sell_id = uct_waste_sell.id
    WHERE uct_waste_sell.id = id;
END;
$$;

CREATE OR REPLACE PROCEDURE uctoo_lvhuan.Trans_fee_sl(IN id int) 
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM Trans_fee_table WHERE FTranType = 'SEL' AND Ffeesence = 'SL' AND FInterID = id;
    INSERT INTO Trans_fee_table
        SELECT
            uct_waste_sell_other_price.sell_id AS FInterID,
            'SEL' AS FTranType,
            'SL' AS Ffeesence,
            uct_waste_sell_other_price.id AS FEntryID,
            uct_waste_sell_other_price.usage AS FFeeID,
            uct_waste_sell_other_price.type AS FFeeType,
            uct_waste_sell_other_price.receiver AS FFeePerson,
            uct_waste_sell_other_price.remark AS FFeeExplain,
            uct_waste_sell_other_price.price AS FFeeAmount,
            '' AS FFeebaseAmount,
            '' AS Ftaxrate,
            '' AS Fbasetax,
            '' AS Fbasetaxamount,
            '' AS FPriceRef,
            to_char(to_timestamp(uct_waste_sell_other_price.createtime), 'YYYY-MM-DD HH24:MI:SS') AS FFeetime,
            NULL AS red_ink_time,
            0 AS is_hedge,
            0
        FROM uct_waste_sell_other_price
        WHERE uct_waste_sell_other_price.sell_id = id;
END;
$$;

CREATE OR REPLACE PROCEDURE uctoo_lvhuan.Trans_fee_so(IN id int) 
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM Trans_fee_table WHERE FTranType = 'SOR' AND Ffeesence = 'SO' AND FInterID = id;
    INSERT INTO Trans_fee_table
        SELECT
            uct_waste_storage_expense.purchase_id AS FInterID,
            'SOR' AS FTranType,
            'SO' AS Ffeesence,
            uct_waste_storage_expense.id AS FEntryID,
            uct_waste_storage_expense.usage AS FFeeID,
            'out' AS FFeeType,
            uct_waste_storage_expense.receiver AS FFeePerson,
            uct_waste_storage_expense.remark AS FFeeExplain,
            uct_waste_storage_expense.price AS FFeeAmount,
            '' AS FFeebaseAmount,
            '' AS Ftaxrate,
            '' AS Fbasetax,
            '' AS Fbasetaxamount,
            '' AS FPriceRef,
            to_char(to_timestamp(uct_waste_storage_expense.createtime), 'YYYY-MM-DD HH24:MI:SS') AS FFeetime,
            NULL AS red_ink_time,
            0 AS is_hedge,
            0
        FROM uct_waste_storage_expense
        WHERE uct_waste_storage_expense.purchase_id = id;
END;
$$;

CREATE OR REPLACE PROCEDURE uctoo_lvhuan.Trans_fee_sor(IN id int) 
LANGUAGE plpgsql
AS $$
BEGIN
    SELECT
        uct_waste_storage_sort.purchase_id AS FInterID,
        'SOR' AS FTranType,
        uct_waste_storage_sort.id AS FEntryID,
        uct_waste_storage_sort.cargo_sort AS FItemID,
        '1' AS FUnitID,
        uct_waste_storage_sort.net_weight AS FQty,
        uct_waste_storage_sort.presell_price AS FPrice,
        round(uct_waste_storage_sort.presell_price * uct_waste_storage_sort.net_weight, 2) AS FAmount,
        '' AS FbasePrice,
        '' AS FbaseAmount,
        '' AS Ftaxrate,
        '' AS Fbasetax,
        '' AS Fbasetaxamount,
        '' AS FPriceRef,
        to_char(to_timestamp(
            CASE 
                WHEN uct_waste_storage_sort.sort_time > uct_waste_storage_sort.createtime THEN uct_waste_storage_sort.sort_time
                ELSE uct_waste_storage_sort.createtime
            END
        ), 'YYYY-MM-DD HH24:MI:SS') AS FDCTime,
        uct_waste_storage_sort.purchase_id AS FSourceInterID,
        'PUR' AS FSourceTranType
    FROM uct_waste_storage_sort
    WHERE uct_waste_storage_sort.purchase_id = id;
END;
$$;

CREATE OR REPLACE PROCEDURE uctoo_lvhuan.Trans_fee_ss(IN id int) 
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM Trans_fee_table WHERE FTranType = 'SOR' AND Ffeesence = 'SS' AND FInterID = id;
    INSERT INTO Trans_fee_table
        SELECT
            uct_waste_storage_sort_expense.purchase_id AS FInterID,
            'SOR' AS FTranType,
            'SS' AS Ffeesence,
            uct_waste_storage_sort_expense.id AS FEntryID,
            uct_waste_storage_sort_expense.usage AS FFeeID,
            'out' AS FFeeType,
            uct_waste_storage_sort_expense.receiver AS FFeePerson,
            uct_waste_storage_sort_expense.remark AS FFeeExplain,
            uct_waste_storage_sort_expense.price AS FFeeAmount,
            '' AS FFeebaseAmount,
            '' AS Ftaxrate,
            '' AS Fbasetax,
            '' AS Fbasetaxamount,
            '' AS FPriceRef,
            to_char(to_timestamp(uct_waste_storage_sort_expense.createtime), 'YYYY-MM-DD HH24:MI:SS') AS FFeetime,
            NULL AS red_ink_time,
            0 AS is_hedge,
            0
        FROM uct_waste_storage_sort_expense
        WHERE uct_waste_storage_sort_expense.purchase_id = id;
END;
$$;


CREATE OR REPLACE PROCEDURE uctoo_lvhuan.Trans_log_pur(IN id int) 
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM Trans_log_table WHERE FTranType = 'PUR' AND FInterID = id;
    INSERT INTO Trans_log_table
    SELECT
        log.purchase_id AS FInterID,
        'PUR' AS FTranType,
        MAX(CASE log.state_value WHEN 'draft' THEN log.createtime END) AS TCreate,
        MAX(CASE log.state_value WHEN 'draft' THEN log.admin_id END) AS TCreatePerson,
        MAX(CASE log.state_value WHEN 'wait_allot' THEN '1' ELSE '0' END) AS TallotOver,
        MAX(CASE log.state_value WHEN 'wait_allot' THEN log.admin_id ELSE NULL END) AS TallotPerson,
        MAX(CASE log.state_value WHEN 'wait_allot' THEN log.createtime ELSE NULL END) AS Tallot,
        MAX(CASE log.state_value WHEN 'wait_receive_order' THEN '1' ELSE '0' END) AS TgetorderOver,
        MAX(CASE log.state_value WHEN 'wait_receive_order' THEN log.admin_id ELSE NULL END) AS TgetorderPerson,
        MAX(CASE log.state_value WHEN 'wait_receive_order' THEN log.createtime ELSE NULL END) AS Tgetorder,
        MAX(CASE log.state_value WHEN 'wait_signin_materiel' THEN '1' ELSE '0' END) AS TmaterialOver,
        MAX(CASE log.state_value WHEN 'wait_signin_materiel' THEN log.admin_id ELSE NULL END) AS TmaterialPerson,
        MAX(CASE log.state_value WHEN 'wait_signin_materiel' THEN log.createtime ELSE NULL END) AS Tmaterial,
        MAX(CASE log.state_value WHEN 'wait_pick_cargo' THEN '1' ELSE '0' END) AS TpurchaseOver,
        MAX(CASE log.state_value WHEN 'wait_pick_cargo' THEN log.admin_id ELSE NULL END) AS TpurchasePerson,
        MAX(CASE log.state_value WHEN 'wait_pick_cargo' THEN log.createtime ELSE NULL END) AS Tpurchase,
        MAX(CASE log.state_value WHEN 'wait_pay' THEN '1' ELSE '0' END) AS TpayOver,
        MAX(CASE log.state_value WHEN 'wait_pay' THEN log.admin_id ELSE NULL END) AS TpayPerson,
        MAX(CASE log.state_value WHEN 'wait_pay' THEN log.createtime ELSE NULL END) AS Tpay,
        MAX(CASE log.state_value WHEN 'wait_storage_connect' THEN '1' ELSE '0' END) AS TchangeOver,
        MAX(CASE log.state_value WHEN 'wait_storage_connect' THEN log.admin_id ELSE NULL END) AS TchangePerson,
        MAX(CASE log.state_value WHEN 'wait_storage_connect' THEN log.createtime ELSE NULL END) AS Tchange,
        MAX(CASE log.state_value WHEN 'wait_storage_connect_confirm' THEN '1' ELSE '0' END) AS TexpenseOver,
        MAX(CASE log.state_value WHEN 'wait_storage_connect_confirm' THEN log.admin_id ELSE NULL END) AS TexpensePerson,
        MAX(CASE log.state_value WHEN 'wait_storage_connect_confirm' THEN log.createtime ELSE NULL END) AS Texpense,
        MAX(CASE log.state_value WHEN 'wait_storage_sort' THEN '1' ELSE '0' END) AS TsortOver,
        MAX(CASE log.state_value WHEN 'wait_storage_sort' THEN log.admin_id ELSE NULL END) AS TsortPerson,
        MAX(CASE log.state_value WHEN 'wait_storage_sort' THEN log.createtime ELSE NULL END) AS Tsort,
        MAX(CASE log.state_value WHEN 'wait_storage_confirm' THEN '1' ELSE '0' END) AS TallowOver,
        MAX(CASE log.state_value WHEN 'wait_storage_confirm' THEN log.admin_id ELSE NULL END) AS TallowPerson,
        MAX(CASE log.state_value WHEN 'wait_storage_confirm' THEN log.createtime ELSE NULL END) AS Tallow,
        MAX(CASE log.state_value WHEN 'finish' THEN '1' ELSE '0' END) AS TcheckOver,
        MAX(CASE log.state_value WHEN 'finish' THEN log.admin_id ELSE NULL END) AS TcheckPerson,
        MAX(CASE log.state_value WHEN 'finish' THEN log.createtime ELSE '0' END) AS Tcheck,
        uct_waste_purchase.state AS State
    FROM uct_waste_purchase
    JOIN uct_waste_purchase_log log ON uct_waste_purchase.id = log.purchase_id
    WHERE uct_waste_purchase.id = id
    AND uct_waste_purchase.hand_mouth_data = '0'
    AND uct_waste_purchase.give_frame = '0'
    GROUP BY uct_waste_purchase.id, uct_waste_purchase.state;
END;
$$;


CREATE OR REPLACE PROCEDURE uctoo_lvhuan.Trans_log_pur_give(IN id int) 
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM Trans_log_table WHERE FTranType = 'PUR' AND FInterID = id;
    INSERT INTO Trans_log_table
    SELECT
        log.purchase_id AS FInterID,
        'PUR' AS FTranType,
        MAX(CASE log.state_value WHEN 'draft' THEN log.createtime END) AS TCreate,
        MAX(CASE log.state_value WHEN 'draft' THEN log.admin_id END) AS TCreatePerson,
        MAX(CASE log.state_value WHEN 'wait_allot' THEN '1' ELSE '0' END) AS TallotOver,
        MAX(CASE log.state_value WHEN 'wait_allot' THEN log.admin_id ELSE NULL END) AS TallotPerson,
        MAX(CASE log.state_value WHEN 'wait_allot' THEN log.createtime ELSE NULL END) AS Tallot,
        MAX(CASE log.state_value WHEN 'wait_receive_order' THEN '1' ELSE '0' END) AS TgetorderOver,
        MAX(CASE log.state_value WHEN 'wait_receive_order' THEN log.admin_id ELSE NULL END) AS TgetorderPerson,
        MAX(CASE log.state_value WHEN 'wait_receive_order' THEN log.createtime ELSE NULL END) AS Tgetorder,
        MAX(CASE log.state_value WHEN 'wait_signin_materiel' THEN '1' ELSE '0' END) AS TmaterialOver,
        MAX(CASE log.state_value WHEN 'wait_signin_materiel' THEN log.admin_id ELSE NULL END) AS TmaterialPerson,
        MAX(CASE log.state_value WHEN 'wait_signin_materiel' THEN log.createtime ELSE NULL END) AS Tmaterial,
        MAX(CASE log.state_value WHEN 'wait_pick_cargo' THEN '1' ELSE '0' END) AS TpurchaseOver,
        MAX(CASE log.state_value WHEN 'wait_pick_cargo' THEN log.admin_id ELSE NULL END) AS TpurchasePerson,
        MAX(CASE log.state_value WHEN 'wait_pick_cargo' THEN log.createtime ELSE NULL END) AS Tpurchase,
        MAX(CASE log.state_value WHEN 'wait_pay' THEN '1' ELSE '0' END) AS TpayOver,
        MAX(CASE log.state_value WHEN 'wait_pay' THEN log.admin_id ELSE NULL END) AS TpayPerson,
        MAX(CASE log.state_value WHEN 'wait_pay' THEN log.createtime ELSE NULL END) AS Tpay,
        MAX(CASE log.state_value WHEN 'wait_storage_connect' THEN '1' ELSE '0' END) AS TchangeOver,
        MAX(CASE log.state_value WHEN 'wait_storage_connect' THEN log.admin_id ELSE NULL END) AS TchangePerson,
        MAX(CASE log.state_value WHEN 'wait_storage_connect' THEN log.createtime ELSE NULL END) AS Tchange,
        NULL AS TexpenseOver,
        NULL AS TexpensePerson,
        NULL AS Texpense,
        NULL AS TsortOver,
        NULL AS TsortPerson,
        NULL AS Tsort,
        MAX(CASE log.state_value WHEN 'wait_storage_connect_confirm' THEN '1' ELSE '0' END) AS TallowOver,
        MAX(CASE log.state_value WHEN 'wait_storage_connect_confirm' THEN log.admin_id ELSE NULL END) AS TallowPerson,
        MAX(CASE log.state_value WHEN 'wait_storage_connect_confirm' THEN log.createtime ELSE NULL END) AS Tallow,
        MAX(CASE log.state_value WHEN 'finish' THEN '1' ELSE '0' END) AS TcheckOver,
        MAX(CASE log.state_value WHEN 'finish' THEN log.admin_id ELSE NULL END) AS TcheckPerson,
        MAX(CASE log.state_value WHEN 'finish' THEN log.createtime ELSE '0' END) AS Tcheck,
        uct_waste_purchase.state AS State
    FROM uct_waste_purchase
    JOIN uct_waste_purchase_log log ON uct_waste_purchase.id = log.purchase_id
    WHERE uct_waste_purchase.id = id
    AND uct_waste_purchase.hand_mouth_data = '0'
    AND uct_waste_purchase.give_frame = '1'
    GROUP BY uct_waste_purchase.id;

END;
$$;

CREATE OR REPLACE PROCEDURE uctoo_lvhuan.Trans_log_pur_hand(IN id int) 
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM Trans_log_table WHERE FTranType = 'PUR' AND FInterID = id;
    INSERT INTO Trans_log_table
    SELECT
        Plog.purchase_id AS FInterID,
        'PUR' AS FTranType,
        MAX(CASE Plog.state_value WHEN 'draft' THEN Plog.createtime END) AS TCreate,
        MAX(CASE Plog.state_value WHEN 'draft' THEN Plog.admin_id END) AS TCreatePerson,
        MAX(CASE Plog.state_value WHEN 'wait_allot' THEN '1' ELSE '0' END) AS TallotOver,
        MAX(CASE Plog.state_value WHEN 'wait_allot' THEN Plog.admin_id END) AS TallotPerson,
        MAX(CASE Plog.state_value WHEN 'wait_allot' THEN Plog.createtime END) AS Tallot,
        MAX(CASE Slog.state_value WHEN 'wait_commit_order' THEN '1' ELSE '0' END) AS TgetorderOver,
        MAX(CASE Slog.state_value WHEN 'wait_commit_order' THEN Slog.admin_id END) AS TgetorderPerson,
        MAX(CASE Slog.state_value WHEN 'wait_commit_order' THEN Slog.createtime END) AS Tgetorder,
        MAX(CASE Plog.state_value WHEN 'wait_receive_order' THEN '1' ELSE '0' END) AS TmaterialOver,
        MAX(CASE Plog.state_value WHEN 'wait_receive_order' THEN Plog.admin_id END) AS TmaterialPerson,
        MAX(CASE Plog.state_value WHEN 'wait_receive_order' THEN Plog.createtime END) AS Tmaterial,
        MAX(CASE Plog.state_value WHEN 'wait_pick_cargo' THEN '1' ELSE '0' END) AS TpurchaseOver,
        MAX(CASE Plog.state_value WHEN 'wait_pick_cargo' THEN Plog.admin_id ELSE NULL END) AS TpurchasePerson,
        MAX(CASE Plog.state_value WHEN 'wait_pick_cargo' THEN Plog.createtime ELSE NULL END) AS Tpurchase,
        MAX(CASE Slog.state_value WHEN 'wait_pay' THEN '1' ELSE '0' END) AS TpayOver,
        MAX(CASE Slog.state_value WHEN 'wait_pay' THEN Slog.admin_id ELSE NULL END) AS TpayPerson,
        MAX(CASE Slog.state_value WHEN 'wait_pay' THEN Slog.createtime ELSE NULL END) AS Tpay,
        MAX(CASE Slog.state_value WHEN 'finish' THEN '1' ELSE '0' END) AS TchangeOver,
        MAX(CASE Slog.state_value WHEN 'finish' THEN Slog.admin_id END) AS TchangePerson,
        MAX(CASE Slog.state_value WHEN 'finish' THEN Slog.createtime END) AS Tchange,
        NULL AS TexpenseOver,
        NULL AS TexpensePerson,
        NULL AS Texpense,
        NULL AS TsortOver,
        NULL AS TsortPerson,
        NULL AS Tsort,
        MAX(CASE Plog.state_value WHEN 'wait_return_fee' THEN '1' ELSE '0' END) AS TallowOver,
        MAX(CASE Plog.state_value WHEN 'wait_return_fee' THEN Plog.admin_id END) AS TallowPerson,
        MAX(CASE Plog.state_value WHEN 'wait_return_fee' THEN Plog.createtime END) AS Tallow,
        MAX(CASE Plog.state_value WHEN 'finish' THEN '1' ELSE '0' END) AS TcheckOver,
        MAX(CASE Plog.state_value WHEN 'finish' THEN Plog.admin_id ELSE NULL END) AS TcheckPerson,
        MAX(CASE Plog.state_value WHEN 'finish' THEN Plog.createtime ELSE '0' END) AS Tcheck,
        P.state AS State
    FROM uct_waste_sell S
    JOIN uct_waste_sell_log Slog ON S.id = Slog.sell_id
    JOIN uct_waste_purchase P ON S.order_id = P.order_id
    JOIN uct_waste_purchase_log Plog ON P.id = Plog.purchase_id
    WHERE Slog.is_timeline_data = '1'
    AND P.id = id
    GROUP BY P.order_id;

END;
$$;


CREATE OR REPLACE PROCEDURE uctoo_lvhuan.Trans_log_sel(IN id int) 
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM Trans_log_table WHERE FTranType = 'SEL' AND FInterID = id;
    INSERT INTO Trans_log_table
    SELECT
        log.sell_id AS FInterID,
        'SEL' AS FTranType,
        MAX(CASE log.state_value WHEN 'draft' THEN log.createtime END) AS TCreate,
        MAX(CASE log.state_value WHEN 'draft' THEN log.admin_id END) AS TCreatePerson,
        NULL AS TallotOver,
        NULL AS TallotPerson,
        NULL AS Tallot,
        NULL AS TgetorderOver,
        NULL AS TgetorderPerson,
        NULL AS Tgetorder,
        NULL AS TmaterialOver,
        NULL AS TmaterialPerson,
        NULL AS Tmaterial,
        MAX(CASE log.state_value WHEN 'wait_weigh' THEN '1' ELSE '0' END) AS TpurchaseOver,
        MAX(CASE log.state_value WHEN 'wait_weigh' THEN log.admin_id ELSE NULL END) AS TpurchasePerson,
        MAX(CASE log.state_value WHEN 'wait_weigh' THEN log.createtime ELSE NULL END) AS Tpurchase,
        NULL AS TpayOver,
        NULL AS TpayPerson,
        NULL AS Tpay,
        NULL AS TchangeOver,
        NULL AS TchangePerson,
        NULL AS Tchange,
        NULL AS TexpenseOver,
        NULL AS TexpensePerson,
        NULL AS Texpense,
        NULL AS TsortOver,
        NULL AS TsortPerson,
        NULL AS Tsort,
        MAX(CASE log.state_value WHEN 'wait_confirm_order' THEN '1' ELSE '0' END) AS TallowOver,
        MAX(CASE log.state_value WHEN 'wait_confirm_order' THEN log.admin_id ELSE NULL END) AS TallowPerson,
        MAX(CASE log.state_value WHEN 'wait_confirm_order' THEN log.createtime ELSE NULL END) AS Tallow,
        MAX(CASE log.state_value WHEN 'wait_pay' THEN '1' ELSE '0' END) AS TcheckOver,
        MAX(CASE log.state_value WHEN 'wait_pay' THEN log.admin_id ELSE NULL END) AS TcheckPerson,
        MAX(CASE log.state_value WHEN 'wait_pay' THEN log.createtime ELSE '0' END) AS Tcheck,
        uct_waste_sell.state AS State
    FROM uct_waste_sell
    JOIN uct_waste_sell_log log ON uct_waste_sell.id = log.sell_id
    WHERE uct_waste_sell.id = id
    AND isnull(uct_waste_sell.purchase_id)
    AND uct_waste_sell.id = id
    GROUP BY uct_waste_sell.id;

END;
$$;

CREATE OR REPLACE PROCEDURE uctoo_lvhuan.Trans_main_pur(IN id int) 
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM Trans_main_table WHERE FTranType = 'PUR' AND FInterID = id;
    INSERT INTO Trans_main_table
    SELECT
        uct_waste_purchase.branch_id AS FRelateBrID,
        uct_waste_purchase.id AS FInterID,
        'PUR' AS FTranType,
        CASE Trans_log_table.TpurchaseOver
            WHEN '0' THEN to_timestamp(0)::text
            ELSE to_timestamp(Trans_log_table.Tpurchase)::text
        END AS FDate,
        CASE Trans_log_table.TpurchaseOver
            WHEN '0' THEN to_date('1970-01-01', 'YYYY-MM-DD')
            ELSE to_date(to_timestamp(Trans_log_table.Tpurchase)::text, 'YYYY-MM-DD')
        END AS Date,
        uct_waste_purchase.train_number AS FTrainNum,
        uct_waste_purchase.order_id AS FBillNo,
        uct_waste_purchase.customer_id AS FSupplyID,
        uct_waste_purchase.manager_id AS Fbusiness,
        'AD' || uct_waste_purchase.purchase_incharge AS FDCStockID,
        'CU' || uct_waste_purchase.customer_id AS FSCStockID,
        CASE uct_waste_purchase.state
            WHEN 'cancel' THEN '0'
            ELSE '1'
        END AS FCancellation,
        '0' AS FROB,
        CASE WHEN Trans_log_table.TpurchaseOver = 1 AND Trans_log_table.FTranType = 'PUR' THEN 1 ELSE 0 END AS FCorrent,
        Trans_log_table.TcheckOver AS FStatus,
        '' AS FUpStockWhenSave,
        '' AS FExplanation,
        '4' AS FDeptID,
        uct_waste_purchase.purchase_incharge AS FEmpID,
        Trans_log_table.TcheckPerson AS FCheckerID,
        CASE Trans_log_table.TcheckOver
            WHEN '0' THEN null
            ELSE to_timestamp(Trans_log_table.Tcheck)::text
        END AS FCheckDate,
        uct_waste_purchase.purchase_incharge AS FFManagerID,
        uct_waste_purchase.purchase_incharge AS FSManagerID,
        uct_waste_purchase.purchase_incharge AS FBillerID,
        '1' AS FCurrencyID,
        Trans_log_table.state AS FNowState,
        CASE uct_waste_purchase.hand_mouth_data
            WHEN '1' THEN '1'
            ELSE '0'
        END + CASE uct_waste_purchase.give_frame
            WHEN '1' THEN '3'
            ELSE 0
        END AS FSaleStyle,
        uct_waste_customer.settle_way AS FPOStyle,
        uct_waste_customer.back_percent AS FPOPrecent,
        round(uct_waste_purchase.cargo_weight, 1) AS TalFQty,
        round(uct_waste_purchase.cargo_price, 2) AS TalFAmount,
        uct_waste_purchase.purchase_expense AS TalFeeFrist,
        Trans_total_fee_rf.car_fee AS TalFeeSecond,
        Trans_total_fee_rf.man_fee AS TalFeeThird,
        Trans_total_fee_rf.other_return_fee AS TalFeeForth,
        0 AS TalFeeFifth,
        0,
        0,
        0,
        0,
        null
    FROM uct_waste_purchase
    JOIN uct_waste_customer ON uct_waste_purchase.customer_id = uct_waste_customer.id
    JOIN Trans_log_table ON uct_waste_purchase.id = Trans_log_table.FInterID
    LEFT JOIN Trans_total_fee_rf ON Trans_total_fee_rf.purchase_id = uct_waste_purchase.id
    WHERE uct_waste_purchase.id = id;

END;
$$;

CREATE OR REPLACE PROCEDURE uctoo_lvhuan.Trans_main_sel(IN id int) 
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM Trans_main_table WHERE FTranType = 'SEL' AND FInterID = id;
    INSERT INTO Trans_main_table
    SELECT
        uct_waste_sell.branch_id AS FRelateBrID,
        uct_waste_sell.id AS FInterID,
        'SEL' AS FTranType,
        CASE Trans_log_table.TallowOver
            WHEN '0' THEN to_timestamp(0)::text
            ELSE to_timestamp(Trans_log_table.Tallow)::text
        END AS FDate,
        CASE Trans_log_table.TallowOver
            WHEN '0' THEN to_date('1970-01-01', 'YYYY-MM-DD')
            ELSE to_date(to_timestamp(Trans_log_table.Tallow)::text, 'YYYY-MM-DD')
        END AS Date,
        '1' AS FTrainNum,
        uct_waste_sell.order_id AS FBillNo,
        uct_waste_sell.customer_id AS FSupplyID,
        '' AS Fbusiness,
        'DC' || uct_waste_sell.customer_id AS FDCStockID,
        CASE WHEN uct_waste_sell.purchase_id IS NOT NULL THEN 'LH' || uct_waste_sell.warehouse_id ELSE '' END AS FSCStockID,
        CASE uct_waste_sell.state
            WHEN 'cancel' THEN '0'
            ELSE '1'
        END AS FCancellation,
        '0' AS FROB,
        Trans_log_table.TallowOver AS FCorrent,
        Trans_log_table.TcheckOver AS FStatus,
        Trans_log_table.TallowOver AS FUpStockWhenSave,
        '' AS FExplanation,
        '4' AS FDeptID,
        uct_waste_sell.seller_id AS FEmpID,
        Trans_log_table.TcheckPerson AS FCheckerID,
        CASE Trans_log_table.TcheckOver
            WHEN '0' THEN null
            ELSE to_timestamp(Trans_log_table.Tcheck)::text
        END AS FCheckDate,
        uct_waste_sell.customer_linkman_id AS FFManagerID,
        uct_waste_sell.customer_linkman_id AS FSManagerID,
        uct_waste_sell.seller_id AS FBillerID,
        '1' AS FCurrencyID,
        Trans_log_table.state AS FNowState,
        CASE WHEN uct_waste_sell.purchase_id IS NOT NULL THEN '1' ELSE '2' END AS FSaleStyle,
        '' AS FPOStyle,
        '' AS FPOPrecent,
        round(uct_waste_sell.cargo_weight, 1) AS TalFQty,
        round(uct_waste_sell.cargo_price, 2) AS TalFAmount,
        uct_waste_sell.materiel_price AS TalFeeFrist,
        uct_waste_sell.other_price AS TalFeeSecond,
        0 AS TalFeeThird,
        0 AS TalFeeForth,
        0 AS TalFeeFifth,
        0,
        0,
        0,
        0,
        null
    FROM uct_waste_sell
    JOIN uct_waste_customer ON uct_waste_sell.customer_id = uct_waste_customer.id
    JOIN Trans_log_table ON uct_waste_sell.id = Trans_log_table.FInterID
    WHERE uct_waste_sell.id = id;

END;
$$;


CREATE OR REPLACE PROCEDURE uctoo_lvhuan.Trans_main_sel_hand(IN id int) 
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM Trans_main_table WHERE FTranType = 'SEL' AND FInterID = id;
    INSERT INTO Trans_main_table
    SELECT
        uct_waste_sell.branch_id AS FRelateBrID,
        uct_waste_sell.id AS FInterID,
        'SEL' AS FTranType,
        CASE Trans_log_table.TallowOver
            WHEN '0' THEN to_timestamp(0)::text
            ELSE to_timestamp(Trans_log_table.Tallow)::text
        END AS FDate,
        CASE Trans_log_table.TallowOver
            WHEN '0' THEN to_date('1970-01-01', 'YYYY-MM-DD')
            ELSE to_date(to_timestamp(Trans_log_table.Tallow)::text, 'YYYY-MM-DD')
        END AS Date,
        '1' AS FTrainNum,
        uct_waste_sell.order_id AS FBillNo,
        uct_waste_sell.customer_id AS FSupplyID,
        '' AS Fbusiness,
        'DC' || uct_waste_sell.customer_id AS FDCStockID,
        CASE WHEN uct_waste_sell.purchase_id IS NOT NULL THEN 'LH' || uct_waste_sell.warehouse_id ELSE '' END AS FSCStockID,
        CASE uct_waste_sell.state
            WHEN 'cancel' THEN '0'
            ELSE '1'
        END AS FCancellation,
        '0' AS FROB,
        Trans_log_table.TallowOver AS FCorrent,
        Trans_log_table.TcheckOver AS FStatus,
        '0' AS FUpStockWhenSave,
        '' AS FExplanation,
        '4' AS FDeptID,
        uct_waste_sell.seller_id AS FEmpID,
        Trans_log_table.TcheckPerson AS FCheckerID,
        CASE Trans_log_table.TcheckOver
            WHEN '0' THEN null
            ELSE to_timestamp(Trans_log_table.Tcheck)::text
        END AS FCheckDate,
        uct_waste_sell.customer_linkman_id AS FFManagerID,
        uct_waste_sell.customer_linkman_id AS FSManagerID,
        uct_waste_sell.seller_id AS FBillerID,
        '1' AS FCurrencyID,
        Trans_log_table.state AS FNowState,
        CASE WHEN uct_waste_sell.purchase_id IS NOT NULL THEN '1' ELSE '2' END AS FSaleStyle,
        '' AS FPOStyle,
        '' AS FPOPrecent,
        round(uct_waste_sell.cargo_weight, 1) AS TalFQty,
        round(uct_waste_sell.cargo_price, 2) AS TalFAmount,
        uct_waste_sell.materiel_price AS TalFeeFrist,
        uct_waste_sell.other_price AS TalFeeSecond,
        0 AS TalFeeThird,
        0 AS TalFeeForth,
        0 AS TalFeeFifth,
        0,
        0,
        0,
        0,
        null
    FROM uct_waste_sell
    JOIN uct_waste_customer ON uct_waste_sell.customer_id = uct_waste_customer.id
    JOIN Trans_log_table ON uct_waste_sell.id = Trans_log_table.FInterID
    WHERE uct_waste_sell.order_id > 201806300000000000
    AND uct_waste_sell.id = id;
END;
$$;

CREATE OR REPLACE PROCEDURE uctoo_lvhuan.Trans_main_sor(IN id int) 
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM Trans_main_table WHERE FTranType = 'SOR' AND FInterID = id;
    INSERT INTO Trans_main_table
    SELECT
        uct_waste_purchase.branch_id AS FRelateBrID,
        uct_waste_purchase.id AS FInterID,
        'SOR' AS FTranType,
        CASE Trans_log_table.TallowOver
            WHEN '0' THEN to_timestamp(0)::text
            ELSE to_timestamp(Trans_log_table.Tallow)::text
        END AS FDate,
        CASE Trans_log_table.TallowOver
            WHEN '0' THEN to_date('1970-01-01', 'YYYY-MM-DD')
            ELSE to_date(to_timestamp(Trans_log_table.Tallow)::text, 'YYYY-MM-DD')
        END AS Date,
        '1' AS FTrainNum,
        uct_waste_purchase.order_id AS FBillNo,
        uct_waste_purchase.customer_id AS FSupplyID,
        uct_waste_purchase.manager_id AS Fbusiness,
        'LH' || uct_waste_warehouse.parent_id AS FDCStockID,
        'AD' || uct_waste_purchase.purchase_incharge AS FSCStockID,
        CASE uct_waste_purchase.state
            WHEN 'cancel' THEN '0'
            ELSE '1'
        END AS FCancellation,
        '0' AS FROB,
        Trans_log_table.TallowOver AS FCorrent,
        Trans_log_table.TcheckOver AS FStatus,
        Trans_log_table.TsortOver AS FUpStockWhenSave,
        '' AS FExplanation,
        uct_waste_customer.service_department AS FDeptID,
        uct_waste_warehouse.admin_id AS FEmpID,
        Trans_log_table.TcheckPerson AS FCheckerID,
        CASE Trans_log_table.TcheckOver
            WHEN '0' THEN null
            ELSE to_timestamp(Trans_log_table.Tcheck)::text
        END AS FCheckDate,
        uct_waste_purchase.purchase_incharge AS FFManagerID,
        uct_waste_warehouse.admin_id AS FSManagerID,
        uct_waste_warehouse.admin_id AS FBillerID,
        '1' AS FCurrencyID,
        Trans_log_table.state AS FNowState,
        '0' + CASE uct_waste_purchase.give_frame
            WHEN '1' THEN '3'
            ELSE '0'
        END AS FSaleStyle,
        uct_waste_customer.settle_way AS FPOStyle,
        uct_waste_customer.back_percent AS FPOPrecent,
        round(uct_waste_purchase.storage_weight, 1) AS TalFQty,
        round(uct_waste_purchase.storage_cargo_price, 2) AS TalFAmount,
        Trans_total_fee_sg.sort_fee AS TalFeeFrist,
        Trans_total_fee_sg.materiel_fee AS TalFeeSecond,
        Trans_total_fee_sg.other_sort_fee AS TalFeeThird,
        uct_waste_purchase.total_cargo_price AS TalFeeForth,
        uct_waste_purchase.total_labor_price AS TalFeeFifth,
        0,
        0,
        0,
        0,
        null
    FROM uct_waste_purchase
    JOIN uct_waste_customer ON uct_waste_purchase.customer_id = uct_waste_customer.id
    JOIN Trans_log_table ON uct_waste_purchase.id = Trans_log_table.FInterID
    JOIN uct_waste_warehouse ON uct_waste_purchase.sort_point = uct_waste_warehouse.id
    LEFT JOIN Trans_total_fee_sg ON Trans_total_fee_sg.purchase_id = uct_waste_purchase.id
    WHERE uct_waste_purchase.order_id > 201806300000000000
    AND uct_waste_purchase.id = id;
END;
$$;

CREATE OR REPLACE PROCEDURE uctoo_lvhuan.Trans_materiel_pur(IN id int) 
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM Trans_materiel_table WHERE FTranType = 'PUR' AND FInterID = id;
    INSERT INTO Trans_materiel_table
    SELECT
        uct_waste_purchase_materiel.purchase_id AS FInterID,
        'PUR' AS FTranType,
        uct_waste_purchase_materiel.id AS FEntryID,
        uct_waste_purchase_materiel.materiel_id AS FMaterielID,
        CAST(uct_waste_purchase_materiel.storage_amount AS integer) AS FUseCount,
        round(uct_waste_purchase_materiel.inside_price, 2) AS FPrice,
        round(CAST(uct_waste_purchase_materiel.storage_amount AS integer) * round(uct_waste_purchase_materiel.inside_price, 2), 2) AS FMeterielAmount,
        uct_waste_purchase_materiel.updatetime AS FMeterieltime,
        NULL AS red_ink_time,
        0 AS is_hedge,
        0
    FROM uct_waste_purchase_materiel
    WHERE uct_waste_purchase_materiel.use_type = 0 AND uct_waste_purchase_materiel.purchase_id = id;
END;
$$;

CREATE OR REPLACE PROCEDURE uctoo_lvhuan.Trans_materiel_sel(IN id int) 
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM Trans_materiel_table WHERE FTranType = 'SEL' AND FInterID = id;
    INSERT INTO Trans_materiel_table
    SELECT
        uct_waste_sell_materiel.sell_id AS FInterID,
        'SEL' AS FTranType,
        uct_waste_sell_materiel.id AS FEntryID,
        uct_waste_sell_materiel.materiel_id AS FMaterielID,
        uct_waste_sell_materiel.pick_amount AS FUseCount,
        uct_waste_sell_materiel.unit_price AS FPrice,
        round(uct_waste_sell_materiel.pick_amount * uct_waste_sell_materiel.unit_price, 2) AS FMeterielAmount,
        uct_waste_sell_materiel.updatetime AS FMeterieltime,
        NULL AS red_ink_time,
        0 AS is_hedge,
        0
    FROM uct_waste_sell_materiel
    WHERE uct_waste_sell_materiel.sell_id = id;
END;
$$;


CREATE OR REPLACE PROCEDURE uctoo_lvhuan.Trans_materiel_sor(IN id int) 
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM Trans_materiel_table WHERE FTranType = 'SOR' AND FInterID = id;
    INSERT INTO Trans_materiel_table
    SELECT
        uct_waste_purchase_materiel.purchase_id AS FInterID,
        'SOR' AS FTranType,
        uct_waste_purchase_materiel.id AS FEntryID,
        uct_waste_purchase_materiel.materiel_id AS FMaterielID,
        CAST(uct_waste_purchase_materiel.pick_amount AS integer) - CAST(uct_waste_purchase_materiel.storage_amount AS integer) AS FUseCount,
        uct_waste_purchase_materiel.inside_price AS FPrice,
        round((CAST(uct_waste_purchase_materiel.pick_amount AS integer) - CAST(uct_waste_purchase_materiel.storage_amount AS integer)) * round(uct_waste_purchase_materiel.inside_price, 2), 2) AS FMeterielAmount,
        uct_waste_purchase_materiel.updatetime AS FMeterieltime,
        NULL AS red_ink_time,
        0 AS is_hedge,
        0
    FROM uct_waste_purchase_materiel
    WHERE uct_waste_purchase_materiel.use_type = 1 AND uct_waste_purchase_materiel.purchase_id = id;
END;
$$;


CREATE OR REPLACE PROCEDURE uctoo_lvhuan.trigger_error_210104() 
LANGUAGE plpgsql
AS $$
BEGIN
    DECLARE id_field int;
    DECLARE order_id_field int;
    DECLARE order_num_field varchar(50);
    DECLARE type_field varchar(5);
    DECLARE hand_mouth_data_field int;
    DECLARE corrent_field int;
    DECLARE handle_field int;
    DECLARE order_type varchar(10);

    DECLARE order_cancel_cur CURSOR FOR 
        SELECT 
            id,
            order_id,
            order_num,
            type,
            hand_mouth_data,
            corrent,
            handle 
        FROM uct_order_cancel 
        GROUP BY order_id, type, hand_mouth_data;
    
    BEGIN
        OPEN order_cancel_cur;
        
        LOOP
            FETCH NEXT FROM order_cancel_cur INTO 
                id_field,
                order_id_field,
                order_num_field,
                type_field,
                hand_mouth_data_field,
                corrent_field,
                handle_field; 

            EXIT WHEN NOT FOUND;

            SET order_type = 'PUR,SOR';
            
            IF type_field = 'SEL' THEN
                SET order_type = 'SEL';
            END IF;

            DELETE FROM Trans_fee_table WHERE FTranType = ANY(string_to_array(order_type, ',')::text[]) AND FInterID = order_id_field;
            INSERT INTO Trans_fee_table 
            SELECT *, null, 0, 0 
            FROM Trans_fee 
            WHERE FTranType = ANY(string_to_array(order_type, ',')::text[]) AND FInterID = order_id_field;

            DELETE FROM Trans_assist_table WHERE FTranType = ANY(string_to_array(order_type, ',')::text[]) AND FInterID = order_id_field;
            INSERT INTO Trans_assist_table 
            SELECT *, null, 0, 0 
            FROM Trans_assist 
            WHERE FTranType = ANY(string_to_array(order_type, ',')::text[]) AND FInterID = order_id_field;

            DELETE FROM Trans_materiel_table WHERE FTranType = ANY(string_to_array(order_type, ',')::text[]) AND FInterID = order_id_field;
            INSERT INTO Trans_materiel_table 
            SELECT *, null, 0, 0 
            FROM Trans_materiel 
            WHERE FTranType = ANY(string_to_array(order_type, ',')::text[]) AND FInterID = order_id_field;

            DELETE FROM Trans_log_table WHERE FTranType = ANY(string_to_array(order_type, ',')::text[]) AND FInterID = order_id_field;
            INSERT INTO Trans_log_table 
            SELECT * 
            FROM Trans_log 
            WHERE FTranType = ANY(string_to_array(order_type, ',')::text[]) AND FInterID = order_id_field;

            DELETE FROM Trans_main_table WHERE FTranType = ANY(string_to_array(order_type, ',')::text[]) AND FInterID = order_id_field;
            INSERT INTO Trans_main_table 
            SELECT *, 0, 0, 0, 0, null 
            FROM Trans_main 
            WHERE FTranType = ANY(string_to_array(order_type, ',')::text[]) AND FInterID = order_id_field;
        END LOOP;
        
        CLOSE order_cancel_cur;
    END;
    
END;
$$;



-- trigger_error_210104_1
CREATE OR REPLACE PROCEDURE uctoo_lvhuan.trigger_error_210104_1() 
LANGUAGE plpgsql
AS $$
BEGIN
    DECLARE id_field int;
    DECLARE order_id_field int;
    DECLARE order_num_field varchar(50);
    DECLARE type_field varchar(5);
    DECLARE hand_mouth_data_field int;
    DECLARE corrent_field int;
    DECLARE handle_field int;
    DECLARE order_type varchar(10);

    DECLARE done BOOLEAN DEFAULT FALSE;

    DECLARE order_cancel_cur CURSOR FOR 
        SELECT 
            1 as id,
            order_id as order_id_field,
            ' ' as order_num_field,
            ' ' as type_field,
            1 as hand_mouth_data_field,
            1 as corrent_field,
            1 as handle_field
        FROM uct_modify_order_audit 
        WHERE createtime >= '2021-01-04' AND createtime < '2021-01-05' AND status = 1;

    BEGIN
        OPEN order_cancel_cur;
        
        LOOP
            FETCH NEXT FROM order_cancel_cur INTO 
                id_field,
                order_id_field,
                order_num_field,
                type_field,
                hand_mouth_data_field,
                corrent_field,
                handle_field; 

            EXIT WHEN NOT FOUND;

            SET order_type = 'PUR,SOR';
            
            IF type_field = 'SEL' THEN
                SET order_type = 'SEL';
            END IF;

            DELETE FROM Trans_fee_table WHERE FTranType = ANY(string_to_array(order_type, ',')::text[]) AND FInterID = order_id_field;
            INSERT INTO Trans_fee_table 
            SELECT *, null, 0, 0 
            FROM Trans_fee 
            WHERE FTranType = ANY(string_to_array(order_type, ',')::text[]) AND FInterID = order_id_field;

            DELETE FROM Trans_assist_table WHERE FTranType = ANY(string_to_array(order_type, ',')::text[]) AND FInterID = order_id_field;
            INSERT INTO Trans_assist_table 
            SELECT *, null, 0, 0 
            FROM Trans_assist 
            WHERE FTranType = ANY(string_to_array(order_type, ',')::text[]) AND FInterID = order_id_field;

            DELETE FROM Trans_materiel_table WHERE FTranType = ANY(string_to_array(order_type, ',')::text[]) AND FInterID = order_id_field;
            INSERT INTO Trans_materiel_table 
            SELECT *, null, 0, 0 
            FROM Trans_materiel 
            WHERE FTranType = ANY(string_to_array(order_type, ',')::text[]) AND FInterID = order_id_field;

            DELETE FROM Trans_log_table WHERE FTranType = ANY(string_to_array(order_type, ',')::text[]) AND FInterID = order_id_field;
            INSERT INTO Trans_log_table 
            SELECT * 
            FROM Trans_log 
            WHERE FTranType = ANY(string_to_array(order_type, ',')::text[]) AND FInterID = order_id_field;

            DELETE FROM Trans_main_table WHERE FTranType = ANY(string_to_array(order_type, ',')::text[]) AND FInterID = order_id_field;
            INSERT INTO Trans_main_table 
            SELECT *, 0, 0, 0, 0, null 
            FROM Trans_main 
            WHERE FTranType = ANY(string_to_array(order_type, ',')::text[]) AND FInterID = order_id_field;
        END LOOP;
        
        CLOSE order_cancel_cur;
    END;
    
END;
$$;


-- trigger_error_210104_2
CREATE OR REPLACE PROCEDURE uctoo_lvhuan.trigger_error_210104_2() 
LANGUAGE plpgsql
AS $$
BEGIN
    DECLARE id_field int;
    DECLARE order_id_field int;
    DECLARE order_num_field varchar(50);
    DECLARE type_field varchar(5);
    DECLARE hand_mouth_data_field int;
    DECLARE corrent_field int;
    DECLARE handle_field int;
    DECLARE order_type varchar(10);

    DECLARE done BOOLEAN DEFAULT FALSE;

    DECLARE order_cancel_cur CURSOR FOR 
        SELECT 
            id,
            order_id,
            order_num,
            type,
            hand_mouth_data,
            corrent,
            handle 
        FROM uct_order_cancel 
        GROUP BY order_id, type, hand_mouth_data
        LIMIT 100 OFFSET 100;

    BEGIN
        OPEN order_cancel_cur;
        
        LOOP
            FETCH NEXT FROM order_cancel_cur INTO 
                id_field,
                order_id_field,
                order_num_field,
                type_field,
                hand_mouth_data_field,
                corrent_field,
                handle_field; 

            EXIT WHEN NOT FOUND;

            SET order_type = 'PUR,SOR';
            
            IF type_field = 'SEL' THEN
                SET order_type = 'SEL';
            END IF;

            DELETE FROM Trans_fee_table WHERE FTranType = ANY(string_to_array(order_type, ',')::text[]) AND FInterID = order_id_field;
            INSERT INTO Trans_fee_table 
            SELECT *, null, 0, 0 
            FROM Trans_fee 
            WHERE FTranType = ANY(string_to_array(order_type, ',')::text[]) AND FInterID = order_id_field;

            DELETE FROM Trans_assist_table WHERE FTranType = ANY(string_to_array(order_type, ',')::text[]) AND FInterID = order_id_field;
            INSERT INTO Trans_assist_table 
            SELECT *, null, 0, 0 
            FROM Trans_assist 
            WHERE FTranType = ANY(string_to_array(order_type, ',')::text[]) AND FInterID = order_id_field;

            DELETE FROM Trans_materiel_table WHERE FTranType = ANY(string_to_array(order_type, ',')::text[]) AND FInterID = order_id_field;
            INSERT INTO Trans_materiel_table 
            SELECT *, null, 0, 0 
            FROM Trans_materiel 
            WHERE FTranType = ANY(string_to_array(order_type, ',')::text[]) AND FInterID = order_id_field;

            DELETE FROM Trans_log_table WHERE FTranType = ANY(string_to_array(order_type, ',')::text[]) AND FInterID = order_id_field;
            INSERT INTO Trans_log_table 
            SELECT * 
            FROM Trans_log 
            WHERE FTranType = ANY(string_to_array(order_type, ',')::text[]) AND FInterID = order_id_field;

            DELETE FROM Trans_main_table WHERE FTranType = ANY(string_to_array(order_type, ',')::text[]) AND FInterID = order_id_field;
            INSERT INTO Trans_main_table 
            SELECT *, 0, 0, 0, 0, null 
            FROM Trans_main 
            WHERE FTranType = ANY(string_to_array(order_type, ',')::text[]) AND FInterID = order_id_field;
        END LOOP;
        
        CLOSE order_cancel_cur;
    END;
    
END;
$$;



-- trigger_error_210104_3
CREATE OR REPLACE PROCEDURE uctoo_lvhuan.trigger_error_210104_3() 
LANGUAGE plpgsql
AS $$
BEGIN
    DECLARE id_field int;
    DECLARE order_id_field int;
    DECLARE order_num_field varchar(50);
    DECLARE type_field varchar(5);
    DECLARE hand_mouth_data_field int;
    DECLARE corrent_field int;
    DECLARE handle_field int;
    DECLARE order_type varchar(10);

    DECLARE done BOOLEAN DEFAULT FALSE;

    DECLARE order_cancel_cur CURSOR FOR 
        SELECT 
            id,
            order_id,
            order_num,
            type,
            hand_mouth_data,
            corrent,
            handle 
        FROM uct_order_cancel 
        GROUP BY order_id, type, hand_mouth_data
        LIMIT 100 OFFSET 200;

    BEGIN
        OPEN order_cancel_cur;
        
        LOOP
            FETCH NEXT FROM order_cancel_cur INTO 
                id_field,
                order_id_field,
                order_num_field,
                type_field,
                hand_mouth_data_field,
                corrent_field,
                handle_field; 

            EXIT WHEN NOT FOUND;

            SET order_type = 'PUR,SOR';
            
            IF type_field = 'SEL' THEN
                SET order_type = 'SEL';
            END IF;

            DELETE FROM Trans_fee_table WHERE FTranType = ANY(string_to_array(order_type, ',')::text[]) AND FInterID = order_id_field;
            INSERT INTO Trans_fee_table 
            SELECT *, null, 0, 0 
            FROM Trans_fee 
            WHERE FTranType = ANY(string_to_array(order_type, ',')::text[]) AND FInterID = order_id_field;

            DELETE FROM Trans_assist_table WHERE FTranType = ANY(string_to_array(order_type, ',')::text[]) AND FInterID = order_id_field;
            INSERT INTO Trans_assist_table 
            SELECT *, null, 0, 0 
            FROM Trans_assist 
            WHERE FTranType = ANY(string_to_array(order_type, ',')::text[]) AND FInterID = order_id_field;

            DELETE FROM Trans_materiel_table WHERE FTranType = ANY(string_to_array(order_type, ',')::text[]) AND FInterID = order_id_field;
            INSERT INTO Trans_materiel_table 
            SELECT *, null, 0, 0 
            FROM Trans_materiel 
            WHERE FTranType = ANY(string_to_array(order_type, ',')::text[]) AND FInterID = order_id_field;

            DELETE FROM Trans_log_table WHERE FTranType = ANY(string_to_array(order_type, ',')::text[]) AND FInterID = order_id_field;
            INSERT INTO Trans_log_table 
            SELECT * 
            FROM Trans_log 
            WHERE FTranType = ANY(string_to_array(order_type, ',')::text[]) AND FInterID = order_id_field;

            DELETE FROM Trans_main_table WHERE FTranType = ANY(string_to_array(order_type, ',')::text[]) AND FInterID = order_id_field;
            INSERT INTO Trans_main_table 
            SELECT *, 0, 0, 0, 0, null 
            FROM Trans_main 
            WHERE FTranType = ANY(string_to_array(order_type, ',')::text[]) AND FInterID = order_id_field;
        END LOOP;
        
        CLOSE order_cancel_cur;
    END;
    
END;
$$;


-- uct_main_effective_table_insert
CREATE OR REPLACE PROCEDURE uctoo_lvhuan.uct_main_effective_table_insert() 
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO uct_main_effective_table (FBillNo, FCorrent, FDate)
    SELECT FBillNo, SUM(FCorrent) as FCorrent, MAX(FDate) AS FDate
    FROM Trans_main_table
    WHERE FSaleStyle <> 2 
    GROUP BY FBillNo
    HAVING SUM(FCorrent) = 2 AND MAX(FDate) BETWEEN '2020-01-01 00:00:00' AND now(); 
END;
$$;


-- updateStockHistory
CREATE OR REPLACE PROCEDURE uctoo_lvhuan.updateStockHistory(branch_id int, centre_branch_id int, warehouse_id varchar(10), cate_id int, sort_time varchar(30)) 
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM Accoding_stock_history 
    WHERE FRelateBrID = centre_branch_id 
    AND FStockID = warehouse_id 
    AND FItemID = cate_id 
    AND FDCTime = date_trunc('day', sort_time::timestamp) + interval '1 day - 1 second'
    AND FdifQty = 0; 

    INSERT INTO Accoding_stock_history 
    SELECT 
        base.FRelateBrID,
        base.FStockID,
        base.FItemID,
        round(SUM(coalesce(base.FDCQty, 0)), 1) AS FDCQty,
        round(SUM(coalesce(base.FSCQty, 0)), 1) AS FSCQty,
        '0' AS FdifQty,
        (date_trunc('day', base.FDCTime::timestamp) + interval '1 day - 1 second') AS FDCTime
    FROM (
        SELECT 
            centre_branch_id AS FRelateBrID,
            CASE Trans_main_table.FTranType
                WHEN 'SOR' THEN Trans_main_table.FDCStockID
                WHEN 'SEL' THEN Trans_main_table.FSCStockID
                ELSE NULL
            END AS FStockID,
            Trans_assist_table.FItemID AS FItemID,
            CASE Trans_main_table.FTranType
                WHEN 'SOR' THEN Trans_assist_table.FQty
                ELSE 0
            END AS FDCQty,
            CASE Trans_main_table.FTranType
                WHEN 'SEL' THEN Trans_assist_table.FQty
                ELSE 0
            END AS FSCQty,
            date_trunc('day', Trans_assist_table.FDCTime::timestamp) AS FDCTime
        FROM Trans_assist_table
        JOIN Trans_main_table 
        ON Trans_assist_table.FinterID = Trans_main_table.FInterID
        AND Trans_assist_table.FTranType = Trans_main_table.FTranType
        AND Trans_main_table.FSaleStyle <> 1
        AND Trans_main_table.FCancellation = 1
        AND (Trans_main_table.FDCStockID = warehouse_id OR Trans_main_table.FSCStockID = warehouse_id)
        AND Trans_assist_table.FItemID = cate_id
        AND date_trunc('day', Trans_assist_table.FDCTime::timestamp) = date_trunc('day', sort_time::timestamp)
    ) base
    GROUP BY base.FRelateBrID, base.FStockID, base.FItemID, base.FDCTime;
END;
$$;


-- update_previous_common_cate
CREATE OR REPLACE PROCEDURE uctoo_lvhuan.update_previous_common_cate() 
LANGUAGE plpgsql
AS $$
BEGIN
    DELETE FROM uct_common_cate WHERE date_unix > EXTRACT(EPOCH FROM NOW()) - 87000;

    INSERT INTO uct_common_cate (branch_id, cate_id, cate_name, src_type, weight, frequency, date_unix)
    SELECT 
        b.branch_id AS branch_id,
        b.id AS cate_id,
        b.name AS cate_name,
        CASE a.FTranType
            WHEN 'PUR' THEN 0
            WHEN 'SOR' THEN 1
            ELSE 2
        END AS src_type,
        ROUND(SUM(COALESCE(a.FQty, 0))) AS weight,
        COUNT(b.id) AS frequency,
        EXTRACT(EPOCH FROM DATE_TRUNC('day', a.FDCTime)) AS date_unix
    FROM Trans_assist_table AS a
    JOIN uct_waste_cate AS b ON a.FItemID = b.id AND b.state = 1
    WHERE a.FDCTime > DATE_TRUNC('day', NOW() - INTERVAL '1 day')
    GROUP BY date_unix, src_type, cate_id
    ORDER BY date_unix;
END;
$$;


CREATE OR REPLACE PROCEDURE uctoo_lvhuan.update_station_task(
    IN p_line_id varchar(20),
    IN p_station_id varchar(20),
    IN p_device_id varchar(20),
    IN p_device_label varchar(20),
    IN p_cate_id integer,
    IN p_cate_name varchar(20),
    IN p_package_no varchar(20),
    IN p_leader integer,
    INOUT p_rv integer,
    INOUT p_err varchar(200)
)
LANGUAGE plpgsql
AS $$
DECLARE 
    v_cate_id integer;
    v_task_id integer;
    v_package_no varchar(20);
    is_exists_package_no integer;
    is_close_package integer;
    is_active_package_no integer;
BEGIN
    SELECT id, cate_id, package_no
    INTO v_task_id, v_cate_id, v_package_no
    FROM uct_sorting_tasks
    WHERE active = 1
        AND line_id = p_line_id
        AND station_id = p_station_id
        AND device_id = p_device_id
    LIMIT 1;

    SELECT COUNT(1) INTO is_exists_package_no
    FROM uct_sorting_tasks
    WHERE package_no = p_package_no;

    SELECT COUNT(1) INTO is_close_package
    FROM uct_sorting_packings
    WHERE package_no = p_package_no AND status = 'close';

    IF v_task_id IS NULL AND is_exists_package_no = 0 AND is_close_package = 0 THEN
        INSERT INTO uct_sorting_tasks (line_id, station_id, device_id, device_label, cate_id, cate_name, active, leader, package_no)
        VALUES (p_line_id, p_station_id, p_device_id, p_device_label, p_cate_id, p_cate_name, 1, p_leader, p_package_no);

        INSERT INTO uct_sorting_packings (package_no, station_id, device_id, cate_id, begin_time, status)
        VALUES (p_package_no, p_station_id, p_device_id, p_cate_id, NOW(), 'open');

        COMMIT;

        p_rv := 200;
        p_err := '已建立新的任务.';
        RETURN;
    END IF;

    IF v_task_id IS NOT NULL AND v_cate_id = p_cate_id AND v_package_no = p_package_no THEN
        p_rv := 201;
        p_err := '提交的数据无变化，未更新.';
        RETURN;
    END IF;

    IF is_close_package > 0 THEN
        p_rv := 502;
        p_err := '这个包装编号已封包了，无法使用了.';
        RETURN;
    END IF;

    SELECT COUNT(1) INTO is_active_package_no
    FROM uct_sorting_tasks
    WHERE active = 1 AND package_no = p_package_no;

    IF is_exists_package_no > 0 AND is_active_package_no > 0 THEN
        p_rv := 501;
        p_err := '这个包装编号正在被使用.';
        RETURN;
    END IF;

    IF is_exists_package_no > 0 AND is_active_package_no = 0 THEN
        INSERT INTO uct_sorting_tasks (line_id, station_id, device_id, device_label, cate_id, cate_name, active, leader, package_no)
        VALUES (p_line_id, p_station_id, p_device_id, p_device_label, p_cate_id, p_cate_name, 2, p_leader, p_package_no);

        UPDATE uct_sorting_tasks
        SET active = active - 1
        WHERE line_id = p_line_id AND station_id = p_station_id AND device_id = p_device_id AND active > 0;

        COMMIT;

        p_rv := 200;
        p_err := '已建立新的任务.';
        RETURN;
    END IF;

    INSERT INTO uct_sorting_tasks (line_id, station_id, device_id, device_label, cate_id, cate_name, active, leader, package_no)
    VALUES (p_line_id, p_station_id, p_device_id, p_device_label, p_cate_id, p_cate_name, 2, p_leader, p_package_no);

    UPDATE uct_sorting_tasks
    SET active = active - 1
    WHERE line_id = p_line_id AND station_id = p_station_id AND device_id = p_device_id AND active > 0;

    INSERT INTO uct_sorting_packings (package_no, station_id, device_id, cate_id, begin_time, status)
    VALUES (p_package_no, p_station_id, p_device_id, p_cate_id, NOW(), 'open');
    COMMIT;

    p_rv := 200;
    p_err := '任务已更新.';
END;
$$;


CREATE OR REPLACE PROCEDURE uctoo_lvhuan.wall_report(IN region_type varchar(20))
LANGUAGE plpgsql
AS $$
DECLARE 
    nowdate date := NOW();
    adcode_where varchar(100);
    customer_where varchar(100);
    customer_group_field varchar(100);
    factory_group_field varchar(100);
    factory_where varchar(100);
BEGIN
    nowdate := DATE_TRUNC('day', NOW() - interval '1 day');

    IF region_type = 'area' THEN       
        adcode_where := 'right(ad.adcode, 4) != ''0000'' and right(ad.adcode, 2) != ''00''';
        customer_where := 'up.company_region';
        customer_group_field := 'company_province, company_city, company_region';
        factory_group_field := 'cf.province, cf.city, cf.area';
        factory_where := 'cf.area';
    ELSIF region_type = 'city' THEN   
        adcode_where := 'right(ad.adcode, 4) != ''0000'' and right(ad.adcode, 2) = ''00''';
        customer_where := 'up.company_city';
        customer_group_field := 'company_province, company_city';
        factory_group_field := 'cf.province, cf.city';
        factory_where := 'cf.city';
    ELSE                                
        adcode_where := 'right(ad.adcode, 4) = ''0000''';
        customer_where := 'up.company_province';
        customer_group_field := 'company_province';
        factory_group_field := 'cf.province';
        factory_where := 'cf.province';
    END IF;

    EXECUTE '
        INSERT INTO uct_day_wall_report (adcode, weight, availability, rubbish, rdf, carbon, box, customer_num, report_date)
        SELECT
            ad.adcode,
            COALESCE(weight, 0) as weight,
            COALESCE(availability, 0) as availability,
            COALESCE(rubbish, 0) as rubbish,
            COALESCE(rdf, 0) as rdf,
            COALESCE(carbon, 0) as carbon,
            COALESCE(box, 0) as box,
            COALESCE(customer.customer_num, 0) as customer_num,
            ''' || nowdate || ''' as report_date
        FROM
            uct_adcode ad
        LEFT JOIN (
            SELECT
                ad.adcode,
                round(sum(FQty), 2) as weight,
                round(sum(CASE WHEN c.name = ''低值废弃物'' THEN FQty ELSE 0 END) / sum(FQty), 2) as availability,
                round(sum(CASE WHEN c.name = ''低值废弃物'' THEN FQty ELSE 0 END), 2) as rubbish,
                round(sum(CASE WHEN c.name = ''低值废弃物'' THEN FQty ELSE 0 END) / sum(FQty) * 4.2, 2) as rdf,
                round(sum(FQty * c2.carbon_parm), 2) as carbon,
                box.box
            FROM
                Trans_main_table mt
            JOIN Trans_main_table mt2 ON mt.FInterId = mt2.FInterId AND mt2.FTranType = ''PUR'' AND mt2.FDate > TO_DATE(''2018-09-30'', ''YYYY-MM-DD'') AND mt2.FDate = ''' || nowdate || '''
            JOIN uct_waste_purchase p ON mt.FBillNo = p.order_id
            JOIN uct_waste_customer_factory cf ON cf.id = p.factory_id
            JOIN uct_adcode ad ON ad.name = ' || factory_where || '
            JOIN Trans_assist_table at ON mt.FInterID = at.FinterID AND mt.FTranType = at.FTranType
            JOIN uct_waste_cate c ON c.id = at.FItemID
            JOIN uct_waste_cate c2 ON c.parent_id = c2.id
            LEFT JOIN (
                SELECT
                    ad.adcode,
                    sum(abs(FUseCount)) as box
                FROM
                    Trans_main_table mt
                JOIN uct_waste_purchase p ON mt.FInterID = p.id
                JOIN uct_waste_customer_factory cf ON cf.id = p.factory_id
                JOIN uct_adcode ad ON ad.name = ' || factory_where || '
                JOIN Trans_materiel_table materiel ON materiel.FInterID = mt.FInterID
                JOIN uct_materiel materiel2 ON materiel.FMaterielID = materiel2.id AND materiel.FTranType in (''PUR'', ''SOR'') AND materiel2.name = ''分类箱''
                WHERE
                    mt.FDate > TO_DATE(''2018-09-30'', ''YYYY-MM-DD'') AND mt.FDate = ''' || nowdate || '''
                    AND mt.FTranType = ''PUR'' AND mt.FSaleStyle in (''0'', ''1'') AND mt.FCorrent = ''1'' AND mt.FCancellation = ''1'' AND mt.FRelateBrID != 7
                GROUP BY ' || factory_group_field || '
            ) box ON box.adcode = ad.adcode
            WHERE
                mt.FTranType in (''SOR'', ''SEL'') AND mt.FSaleStyle in (''0'', ''1'') AND mt.FCorrent = ''1'' AND mt.FCancellation = ''1'' AND mt.FRelateBrID != 7
            GROUP BY ' || factory_group_field || '
        ) data ON ad.adcode = data.adcode
        LEFT JOIN (
            SELECT
                ad.adcode,
                count(*) as customer_num
            FROM
                uct_up up
            JOIN uct_adcode ad ON ' || customer_where || ' = ad.name AND first_business_time = ''' || nowdate || '''
            GROUP BY ' || customer_group_field || '
        ) customer ON customer.adcode = ad.adcode
        WHERE ' || adcode_where;
END;
$$;



CREATE OR REPLACE PROCEDURE uctoo_lvhuan.warehouse_daily_report(IN _begin_time DATE, IN _end_time DATE)
LANGUAGE plpgsql
AS $$
DECLARE 
    _test_date DATE := _begin_time;
BEGIN
    -- Loop through the dates from _begin_time to _end_time
    WHILE _test_date <= _end_time LOOP
        -- Insert data into lh_dw.data_statistics_results for stock-in
        INSERT INTO lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, val1, val2, val3)
        SELECT 'D' as time_dims,
               _test_date - INTERVAL '1 DAY' as time_val,
               (_test_date - INTERVAL '1 DAY')::DATETIME as begin_time,
               _test_date::DATETIME as end_time,
               '分部' as data_dims,
               b.centre_branch_id as data_val,
               'warehouse-daily-report' as stat_code,
               'stock-in' as group1,
               ROUND(COALESCE(SUM(IFNULL(at.FQty, 0)), 0), 2) as val1,
               ROUND(COALESCE(SUM(IFNULL(at.FQty, 0)), 0) - COALESCE(r.val1, 0), 2) as val2,
               COALESCE(ROUND((COALESCE(SUM(IFNULL(at.FQty, 0)), 0) - COALESCE(r.val1, 0)) / COALESCE(r.val1, 0), 2), 0) * 100 as val3
        FROM Trans_assist_table at
        RIGHT JOIN Trans_main_table mt ON mt.FInterID = at.FinterID AND mt.FTranType = at.FTranType AND mt.FCancellation = 1 AND mt.FSaleStyle = 0 AND mt.FTranType = 'SOR' AND date_trunc('day', at.FDCTime) = _test_date - INTERVAL '1 DAY'
        RIGHT JOIN uct_branch b ON b.setting_key = mt.FRelateBrID
        LEFT JOIN lh_dw.data_statistics_results as r ON r.data_val = CAST(b.centre_branch_id as CHAR) AND r.time_dims = 'D' AND r.time_val = (_test_date - INTERVAL '2 DAY')::DATE AND r.data_dims = '分部' AND r.stat_code = 'warehouse-daily-report' AND r.group1 = 'stock-in'
        GROUP BY b.centre_branch_id;

        -- Insert data into lh_dw.data_statistics_results for stock-out
        INSERT INTO lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, val1, val2, val3)
        SELECT 'D' as time_dims,
               _test_date - INTERVAL '1 DAY' as time_val,
               (_test_date - INTERVAL '1 DAY')::DATETIME as begin_time,
               _test_date::DATETIME as end_time,
               '分部' as data_dims,
               b.setting_key as data_val,
               'warehouse-daily-report' as stat_code,
               'stock-out' as group1,
               ROUND(COALESCE(SUM(IFNULL(mt.TalFQty, 0)), 0), 2) as val1,
               ROUND(COALESCE(SUM(IFNULL(mt.TalFQty, 0)), 0) - COALESCE(r.val1, 0), 2) as val2,
               COALESCE(ROUND((COALESCE(SUM(IFNULL(mt.TalFQty, 0)), 0) - COALESCE(r.val1, 0)) / COALESCE(r.val1, 0), 2), 0) * 100 as val3
        FROM Trans_main_table mt
        RIGHT JOIN lh_dw.data_statistics_results as r ON r.data_val = mt.FRelateBrID AND mt.FCancellation = 1 AND mt.FCorrent = 1 AND mt.FSaleStyle = 2 AND mt.FTranType = 'SEL' AND mt."Date" = _test_date - INTERVAL '1 DAY'
        RIGHT JOIN uct_branch as b ON CAST(b.setting_key as CHAR) = r.data_val AND r.time_dims = 'D' AND r.time_val = (_test_date - INTERVAL '2 DAY')::DATE AND r.data_dims = '分部' AND r.stat_code = 'warehouse-daily-report' AND r.group1 = 'stock-out'
        GROUP BY b.setting_key;

        -- Insert data into lh_dw.data_statistics_results for order-status-count wait_storage_sort
        INSERT INTO lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, val1, val2, val3)
        SELECT 'D' as time_dims,
               _test_date - INTERVAL '1 DAY' as time_val,
               (_test_date - INTERVAL '1 DAY')::DATETIME as begin_time,
               _test_date::DATETIME as end_time,
               '分部' as data_dims,
               b.setting_key as data_val,
               'warehouse-daily-report' as stat_code,
               'order-status-count' as group1,
               'wait_storage_sort' as group2,
               SUM(CASE WHEN mt.FNowState = 'wait_storage_sort' THEN 1 ELSE 0 END) as val1,
               SUM(CASE WHEN mt.FNowState = 'wait_storage_sort' THEN 1 ELSE 0 END) - COALESCE(r.val1, 0) as val2,
               COALESCE(ROUND((SUM(CASE WHEN mt.FNowState = 'wait_storage_sort' THEN 1 ELSE 0 END) - COALESCE(r.val1, 0)) / COALESCE(r.val1, 0), 2), 0) * 100 as val3
        FROM Trans_main_table mt
        RIGHT JOIN lh_dw.data_statistics_results as r ON r.data_val = mt.FRelateBrID AND mt.FCancellation = 1 AND mt.FSaleStyle IN (0, 3) AND mt.FTranType = 'PUR' AND date_trunc('day', mt."Date") = _test_date - INTERVAL '1 DAY'
        RIGHT JOIN uct_branch as b ON CAST(b.setting_key as CHAR) = r.data_val AND r.time_dims = 'D' AND r.time_val = (_test_date - INTERVAL '2 DAY')::DATE AND r.data_dims = '分部' AND r.stat_code = 'warehouse-daily-report' AND r.group1 = 'order-status-count' AND r.group2 = 'wait_storage_sort'
        GROUP BY b.setting_key;

        -- Insert data into lh_dw.data_statistics_results for order-status-count wait_pick_cargo
        INSERT INTO lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, val1, val2, val3)
        SELECT 'D' as time_dims,
               _test_date - INTERVAL '1 DAY' as time_val,
               (_test_date - INTERVAL '1 DAY')::DATETIME as begin_time,
               _test_date::DATETIME as end_time,
               '分部' as data_dims,
               b.setting_key as data_val,
               'warehouse-daily-report' as stat_code,
               'order-status-count' as group1,
               'wait_pick_cargo' as group2,
               SUM(CASE WHEN mt.FNowState = 'wait_pick_cargo' THEN 1 ELSE 0 END) as val1,
               SUM(CASE WHEN mt.FNowState = 'wait_pick_cargo' THEN 1 ELSE 0 END) - COALESCE(r.val1, 0) as val2,
               COALESCE(ROUND((SUM(CASE WHEN mt.FNowState = 'wait_pick_cargo' THEN 1 ELSE 0 END) - COALESCE(r.val1, 0)) / COALESCE(r.val1, 0), 2), 0) * 100 as val3
        FROM Trans_main_table mt
        RIGHT JOIN lh_dw.data_statistics_results as r ON r.data_val = mt.FRelateBrID AND mt.FCancellation = 1 AND mt.FSaleStyle IN (0, 3) AND mt.FTranType = 'PUR' AND date_trunc('day', mt."Date") = _test_date - INTERVAL '1 DAY'
        RIGHT JOIN uct_branch as b ON CAST(b.setting_key as CHAR) = r.data_val AND r.time_dims = 'D' AND r.time_val = (_test_date - INTERVAL '2 DAY')::DATE AND r.data_dims = '分部' AND r.stat_code = 'warehouse-daily-report' AND r.group1 = 'order-status-count' AND r.group2 = 'wait_pick_cargo'
        GROUP BY b.setting_key;

        -- Insert data into lh_dw.data_statistics_results for order-status-count wait_deliver_cargo
        INSERT INTO lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, val1, val2, val3)
        SELECT 'D' as time_dims,
               _test_date - INTERVAL '1 DAY' as time_val,
               (_test_date - INTERVAL '1 DAY')::DATETIME as begin_time,
               _test_date::DATETIME as end_time,
               '分部' as data_dims,
               b.setting_key as data_val,
               'warehouse-daily-report' as stat_code,
               'order-status-count' as group1,
               'wait_deliver_cargo' as group2,
               SUM(CASE WHEN mt.FNowState = 'wait_deliver_cargo' THEN 1 ELSE 0 END) as val1,
               SUM(CASE WHEN mt.FNowState = 'wait_deliver_cargo' THEN 1 ELSE 0 END) - COALESCE(r.val1, 0) as val2,
               COALESCE(ROUND((SUM(CASE WHEN mt.FNowState = 'wait_deliver_cargo' THEN 1 ELSE 0 END) - COALESCE(r.val1, 0)) / COALESCE(r.val1, 0), 2), 0) * 100 as val3
        FROM Trans_main_table mt
        RIGHT JOIN lh_dw.data_statistics_results as r ON r.data_val = mt.FRelateBrID AND mt.FCancellation = 1 AND mt.FSaleStyle IN (0, 3) AND mt.FTranType = 'PUR' AND date_trunc('day', mt."Date") = _test_date - INTERVAL '1 DAY'
        RIGHT JOIN uct_branch as b ON CAST(b.setting_key as CHAR) = r.data_val AND r.time_dims = 'D' AND r.time_val = (_test_date - INTERVAL '2 DAY')::DATE AND r.data_dims = '分部' AND r.stat_code = 'warehouse-daily-report' AND r.group1 = 'order-status-count' AND r.group2 = 'wait_deliver_cargo'
        GROUP BY b.setting_key;

        -- Insert data into lh_dw.data_statistics_results for order-status-count wait_send_cargo
        INSERT INTO lh_dw.data_statistics_results (time_dims, time_val, begin_time, end_time, data_dims, data_val, stat_code, group1, group2, val1, val2, val3)
        SELECT 'D' as time_dims,
               _test_date - INTERVAL '1 DAY' as time_val,
               (_test_date - INTERVAL '1 DAY')::DATETIME as begin_time,
               _test_date::DATETIME as end_time,
               '分部' as data_dims,
               b.setting_key as data_val,
               'warehouse-daily-report' as stat_code,
               'order-status-count' as group1,
               'wait_send_cargo' as group2,
               SUM(CASE WHEN mt.FNowState = 'wait_send_cargo' THEN 1 ELSE 0 END) as val1,
               SUM(CASE WHEN mt.FNowState = 'wait_send_cargo' THEN 1 ELSE 0 END) - COALESCE(r.val1, 0) as val2,
               COALESCE(ROUND((SUM(CASE WHEN mt.FNowState = 'wait_send_cargo' THEN 1 ELSE 0 END) - COALESCE(r.val1, 0)) / COALESCE(r.val1, 0), 2), 0) * 100 as val3
        FROM Trans_main_table mt
        RIGHT JOIN lh_dw.data_statistics_results as r ON r.data_val = mt.FRelateBrID AND mt.FCancellation = 1 AND mt.FSaleStyle IN (0, 3) AND mt.FTranType = 'PUR' AND date_trunc('day', mt."Date") = _test_date - INTERVAL '1 DAY'
        RIGHT JOIN uct_branch as b ON CAST(b.setting_key as CHAR) = r.data_val AND r.time_dims = 'D' AND r.time_val = (_test_date - INTERVAL '2 DAY')::DATE AND r.data_dims = '分部' AND r.stat_code = 'warehouse-daily-report' AND r.group1 = 'order-status-count' AND r.group2 = 'wait_send_cargo'
        GROUP BY b.setting_key;

        -- Increment _test_date for the next iteration
        _test_date := _test_date + INTERVAL '1 DAY';
    END LOOP;
END;
$$;





