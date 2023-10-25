DROP TRIGGER IF EXISTS purchase_trigger ON test_lvhuan.uct_waste_purchase ;


CREATE OR REPLACE FUNCTION "test_lvhuan"."test_lvhuan_purchase_trigger"()
RETURNS TRIGGER AS $$
DECLARE
    id INT;
    order_num VARCHAR;
    type VARCHAR;
    hand_mouth_data VARCHAR;
    corrent INT;
BEGIN
    IF NEW.state = 'cancel' THEN
        id := NEW.id;
        order_num := NEW.order_id;
        type := 'PUR';
        hand_mouth_data := NEW.hand_mouth_data;
        corrent := 0;

        SELECT FCorrent INTO corrent FROM Trans_main_table WHERE FInterID = id AND FTranType = 'PUR';

        INSERT INTO uct_order_cancel(order_id, order_num, type, hand_mouth_data, corrent) 
        VALUES (id, order_num, type, hand_mouth_data, corrent);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER purchase_trigger 
AFTER UPDATE ON test_lvhuan.uct_waste_purchase 
FOR EACH ROW 
EXECUTE FUNCTION "test_lvhuan"."test_lvhuan_purchase_trigger"();






CREATE OR REPLACE FUNCTION "test_lvhuan"."test_lvhuan_sell_trigger"() 
RETURNS TRIGGER AS $$
DECLARE
    id INT;
    order_num VARCHAR;
    type VARCHAR := 'SEL';
    hand_mouth_data INT;  -- Assuming INT type, modify if different
    corrent INT;
BEGIN
    IF NEW.state = 'cancel' THEN
        id := NEW.id;
        order_num := NEW.order_id;
        hand_mouth_data := NEW.purchase_id;
        corrent := 0;

        SELECT FCorrent INTO corrent FROM Trans_main_table WHERE FInterID = id AND FTranType = 'SEL';

        IF hand_mouth_data > 0 THEN
            hand_mouth_data := 1;
        ELSE
            hand_mouth_data := 0;
        END IF;

        INSERT INTO uct_order_cancel(order_id, order_num, type, hand_mouth_data, corrent) 
        VALUES (id, order_num, type, hand_mouth_data, corrent);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER sell_trigger 
AFTER UPDATE ON test_lvhuan.uct_waste_sell 
FOR EACH ROW 
EXECUTE FUNCTION "test_lvhuan"."test_lvhuan_sell_trigger"();