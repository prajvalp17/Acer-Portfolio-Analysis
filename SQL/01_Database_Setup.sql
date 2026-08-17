DROP DATABASE IF EXISTS acer_portfolio;

CREATE DATABASE acer_portfolio;

USE acer_portfolio;

CREATE TABLE products (
    part_number VARCHAR(30) PRIMARY KEY,
    series VARCHAR(50) NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    fsn VARCHAR(50),
    asin VARCHAR(50),
    myntra_sku_code VARCHAR(100),
    mrp DECIMAL(12,2),
    size VARCHAR(30),
    colour VARCHAR(50),
    material VARCHAR(100),
    opening_type VARCHAR(50),
    expandable VARCHAR(10),
    notes VARCHAR(255)
);

CREATE TABLE marketplaces (
    marketplace_id INT PRIMARY KEY,
    marketplace_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE inventory_sales (
    part_number VARCHAR(30) PRIMARY KEY,
    acer_stock INT DEFAULT 0,
    flipkart_stock INT DEFAULT 0,
    amazon_stock INT DEFAULT 0,
    myntra_stock INT DEFAULT 0,
    flipkart_sales INT DEFAULT 0,
    amazon_sales INT DEFAULT 0,
    myntra_sales INT DEFAULT 0,
    total_inventory INT DEFAULT 0,
    total_sales INT DEFAULT 0,
    inventory_value DECIMAL(15,2) DEFAULT 0,
    CONSTRAINT fk_inventory_product
        FOREIGN KEY (part_number)
        REFERENCES products(part_number)
);

INSERT INTO marketplaces (marketplace_id, marketplace_name) VALUES
(1, 'Flipkart'),
(2, 'Amazon'),
(3, 'Myntra');