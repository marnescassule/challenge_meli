-- Challenge para Inginiero de Datos no Mercado Libre
-- Candidato: Marnes Cassule

-- Query respondendo
--1. Listar los usuarios que cumplan años el día de hoy cuya cantidad de ventas realizadas en enero 2020 sea superior a 1500.

SELECT
    c.email,
    c.nombre,
    c.apellido,
    COUNT(DISTINCT o.id) AS total_orders
FROM Customer c
INNER JOIN OrderTable o ON o.customer_email = c.email
WHERE c.fecha_nacimiento = CURRENT_DATE()
AND o.fecha_compra BETWEEN '2020-01-01' AND '2020-01-31'
GROUP BY c.email, c.nombre, c.apellido
HAVING total_orders > 1500;

--2. Por cada mes del 2020, se solicita el top 5 de usuarios que más vendieron($) en la categoría Celulares. Se requiere el mes y año de análisis, nombre y apellido del vendedor, cantidad de ventas realizadas, cantidad de productos vendidos y el monto total transaccionado.
SELECT
    DATE_FORMAT(o.fecha_compra, '%m') AS mes,
    DATE_FORMAT(o.fecha_compra, '%Y') AS anio,
    c.nombre,
    c.apellido,
    COUNT(DISTINCT o.id) AS cantidad_ventas,
    SUM(o.cantidad) AS cantidad_productos,
    SUM(o.monto_total) AS monto_total
FROM Order o
INNER JOIN Customer c ON c.email = o.customer_id
INNER JOIN Item i ON i.id = o.item_id
INNER JOIN Category cat ON cat.id = i.categoria_id
WHERE cat.path LIKE '%Celulares%'
GROUP BY mes, anio, c.email
ORDER BY monto_total DESC
LIMIT 5;

-- 3. Se solicita poblar una nueva tabla con el precio y estado de los Ítems a fin del día.
-- Tener en cuenta que debe ser reprocesable. Vale resaltar que en la tabla Item,
-- vamos a tener únicamente el último estado informado por la PK definida. (Se puede
-- resolver a través de StoredProcedure)

CREATE TABLE DailyItemState (
    item_id INT NOT NULL,
    date DATE NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    state ENUM('active', 'inactive', 'sold', 'other') NOT NULL,
    PRIMARY KEY (item_id, date),
    FOREIGN KEY fk_item_id (item_id) REFERENCES Item(id)
);

-- Ponto Extra
-- Podemos crear un Procedimiento Almacenado para ejecutarse diariamente. Este procedimiento realizará las siguientes acciones:

--Obtendrá la fecha actual.
-- Iterará a través de todos los elementos en la tabla Item.
-- Para cada elemento, extraerá el precio y estado de la tabla Item.
-- Insertará un nuevo registro en la tabla DailyItemState con el ID del elemento, la fecha actual, el precio y el estado.

DELIMITER //

CREATE PROCEDURE UpdateDailyItemState()
BEGIN
    DECLARE currentDate DATE DEFAULT CURDATE();
    DECLARE itemId INT;
    DECLARE itemPrice DECIMAL(10,2);
    DECLARE itemState VARCHAR(255);

    DECLARE itemCursor CURSOR FOR SELECT id, precio, estado FROM Item;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET DONE = TRUE;

    OPEN itemCursor;

    item_loop: LOOP
        FETCH itemCursor INTO itemId, itemPrice, itemState;
        IF DONE THEN
            LEAVE item_loop;
        END IF;

        BEGIN
            -- Tente atualizar se já existir um registro para a mesma data e item_id
            INSERT INTO DailyItemState (item_id, date, price, state)
            VALUES (itemId, currentDate, itemPrice, itemState)
            ON DUPLICATE KEY UPDATE
                price = VALUES(price),
                state = VALUES(state);
        END;
    END LOOP;

    CLOSE itemCursor;
END //

DELIMITER ;