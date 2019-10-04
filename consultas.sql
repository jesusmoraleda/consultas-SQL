--1 
SELECT * FROM CLIENTES
ORDER BY APELLIDO;

--2 
SELECT DISTINCT NOMBRE, DECODE(DIASEMANA, 'L', 'LUNES',
                                          'M', 'MARTES',
                                          'X', 'MIERCOLES',
                                          'J', 'JUEVES',
                                          'V', 'VIERNES',
                                          'S', 'SABADO',
                                          'D', 'DOMINGO',
                                              'NO-DAY') AS DIA_SEMANA,
to_char(HO.HORA_APERTURA,'HH:MI') AS HORA_APERTURA , to_char(HO.HORA_CIERRE, 'HH:MI') AS HORA_CIERRE
FROM HORARIOS HO, RESTAURANTES RES
WHERE HO.RESTAURANTE = RES.CODIGO
ORDER BY NOMBRE;

--3 
SELECT CL.DNI, CL.NOMBRE, CL.APELLIDO
FROM CLIENTES CL, PEDIDOS PE, PLATOS PL, CONTIENE CO
WHERE PL.CATEGORIA = 'picante' AND PE.CLIENTE = CL.DNI AND CO.PEDIDO = PE.CODIGO AND CO.PLATO = PL.NOMBRE;

--4
SELECT PEDIDOS.CODIGO, CLIENTES.NOMBRE, CLIENTES.TELEFONO
FROM PEDIDOS, CLIENTES
WHERE PEDIDOS.CLIENTE = CLIENTES.DNI AND PEDIDOS.IMPORTETOTAL > 100;

--5
SELECT CLIENTES.DNI, CLIENTES.NOMBRE
FROM CLIENTES
WHERE NOT EXISTS (SELECT CLIENTES.DNI, CLIENTES.NOMBRE
                  FROM PEDIDOS 
                  WHERE PEDIDOS.CLIENTE = CLIENTES.DNI);

--6 (NINGUN CLIENTE COMPARTE TELEFONO) SE HA COMPROBADO INSERTAR UN CLIENTE NUEVO CON UN MISMO NUMERO DE TELEFONO Y FUNCIONA
SELECT DNI
FROM CLIENTES CL
WHERE TELEFONO = (SELECT CLIENTES.TELEFONO
                  FROM CLIENTES 
                  WHERE CL.TELEFONO = CLIENTES.TELEFONO AND CL.DNI != CLIENTES.DNI);


--7 NO HAY NINGUN CLIENTE QUE HAYA PEDIDO PLATOS EN TODOS LOS RESTAURANTES
-- NO ESTA DEL TODO BIEN (NO FUNCIONA) PERO ES ALGO ASI
SELECT DNI 
FROM CLIENTES
WHERE NOT EXISTS (SELECT CODIGO FROM RESTAURANTES)
MINUS
SELECT RESTAURANTES.CODIGO
FROM CONTIENE, PEDIDOS, RESTAURANTES
WHERE CONTIENE.PEDIDO = PEDIDOS.CODIGO AND CONTIENE.RESTAURANTE = RESTAURANTES.CODIGO AND PEDIDOS.CLIENTE = DNI;


--8 EN ESTE CASO SE CONSIDERA QUE EL ESTADO 'REST' ES QUE EL CLIENTE AUN NO HA RECIBIDO EL PEDIDO
SELECT DISTINCT DNI, NOMBRE, APELLIDO
FROM CLIENTES, PEDIDOS
WHERE PEDIDOS.CLIENTE = CLIENTES.DNI AND ESTADO = 'RUTA' OR ESTADO = 'REST';

-- MIENTRAS QUE EN ESTE SOLO SE CONSIDERA COMO NO RECIBIDO LOS 'RUTA'
SELECT DISTINCT DNI, NOMBRE, APELLIDO
FROM CLIENTES, PEDIDOS
WHERE PEDIDOS.CLIENTE = CLIENTES.DNI AND ESTADO = 'RUTA';

--9 CON PONER  EN LA CLAUSULA SELECT EL * (SELECT *) SALDRIA TAN SOLO LA FECHA. PARA QUE SALGA LA FECHA Y HORA:
SELECT CODIGO, ESTADO,
to_char(FECHA_HORA_PEDIDO,'DD-MM-YY:HH:MI') AS FECHA_HORA_PEDIDO, to_char(FECHA_HORA_ENTREGA, 'DD-MM-YY:HH:MI') AS FECHA_HORA_ENTREGA, 
IMPORTETOTAL, CLIENTE, CODIGODESCUENTO
FROM PEDIDOS
WHERE IMPORTETOTAL = (SELECT MAX(IMPORTETOTAL) FROM PEDIDOS);

--10 
SELECT TRUNC(AVG(PE.IMPORTETOTAL),2) AS VALOR_MEDIO, CL.DNI, CL.NOMBRE, CL.APELLIDO
FROM CLIENTES CL, PEDIDOS PE
WHERE PE.CLIENTE = CL.DNI
GROUP BY CL.DNI, CL.NOMBRE, CL.APELLIDO;

--11
SELECT DISTINCT RE.CODIGO, RE.NOMBRE, SUM(CO.UNIDADES) AS TOTAL_PLATOS, SUM(PL.PRECIO*CO.UNIDADES) AS PRECIO_ACUM
FROM PEDIDOS PE, PLATOS PL, CONTIENE CO, RESTAURANTES RE
WHERE CO.PEDIDO = PE.CODIGO AND CO.PLATO = PL.NOMBRE  AND CO.RESTAURANTE = RE.CODIGO AND PL.RESTAURANTE = RE.CODIGO
GROUP BY RE.CODIGO, RE.NOMBRE;

--CON LOS DESCUENTOS
SELECT DISTINCT RE.CODIGO, RE.NOMBRE, SUM(CO.UNIDADES) AS TOTAL_PLATOS, SUM(PL.PRECIO*CO.UNIDADES-(PL.PRECIO*CO.UNIDADES*DE.PORCENTAJE_DESCUENTO/100)) AS PRECIO_ACUM
FROM PEDIDOS PE, PLATOS PL, CONTIENE CO, RESTAURANTES RE, DESCUENTOS DE, APLICADOSA AA
WHERE CO.PEDIDO = PE.CODIGO AND CO.PLATO = PL.NOMBRE  AND CO.RESTAURANTE = RE.CODIGO AND PL.RESTAURANTE = RE.CODIGO
      AND AA.CODIGODESC = DE.CODIGO AND AA.CODIGOPED = PE.CODIGO
GROUP BY RE.CODIGO, RE.NOMBRE;

--12
SELECT DISTINCT CL.NOMBRE, CL.APELLIDO
FROM CLIENTES CL, PEDIDOS PE, CONTIENE CO, PLATOS PL 
WHERE CL.DNI = PE.CLIENTE AND CO.PEDIDO = PE.CODIGO AND CO.PLATO = PL.NOMBRE AND PL.PRECIO > 15;

--13
SELECT DISTINCT CL.DNI, CL.NOMBRE, CL.APELLIDO, COUNT(AC.RESTAURANTE) AS NUM_REST
FROM CLIENTES CL, AREASCOBERTURA AC
WHERE CL.CODIGOPOSTAL = AC.CODIGOPOSTAL
GROUP BY CL.DNI, CL.NOMBRE, CL.APELLIDO;
