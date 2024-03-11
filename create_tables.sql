-- Challenge para Inginiero de Datos no Mercado Libre
-- Candidato: Marnes Cassule
-- 1. Primeira Parte
--  Customer
CREATE TABLE Customer (
    email VARCHAR(255) PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    apellido VARCHAR(255) NOT NULL,
    sexo CHAR(1) NOT NULL,
    direccion VARCHAR(255) NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    telefono VARCHAR(255) NOT NULL
);

-- Item
CREATE TABLE Item (
    id INT PRIMARY KEY AUTO_INCREMENT,
    descripcion VARCHAR(255) NOT NULL,
    precio DECIMAL(10,2) NOT NULL,
    estado VARCHAR(255) NOT NULL,
    fecha_baja DATE,
    categoria_id INT NOT NULL,
    FOREIGN KEY (categoria_id) REFERENCES Category(id)
);

-- Category
CREATE TABLE Category (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nombre VARCHAR(255) NOT NULL,
    path VARCHAR(255) NOT NULL
);

-- Order
CREATE TABLE Order (
    id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    item_id INT NOT NULL,
    cantidad INT NOT NULL,
    fecha_compra DATETIME NOT NULL,
    monto_total DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES Customer(email),
    FOREIGN KEY (item_id) REFERENCES Item(id)
);
