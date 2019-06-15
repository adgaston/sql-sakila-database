USE sakila;

-- 1a) Display first & last name of actors
SELECT first_name, last_name
FROM actor;

-- 1b) Display first & last name of actors together in single column: Actor Name
SELECT CONCAT(`first_name`, ' ', `last_name`) as `Actor Name` FROM `actor`;


-- 2a) Find: ID #, first name & last name, for actor with first name of Joe
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = "JOE";

-- 2b) Find all actors with GEN in last name
SELECT first_name, last_name
FROM actor
WHERE last_name LIKE "%GEN%";

-- 2c) Find all actors with LI in last name
SELECT first_name, last_name
FROM actor
WHERE last_name LIKE "%LI%";

-- 2d) Use IN & display 'country_id' & 'country' colums of: Afghanistan, Bangladesh, China
SELECT country_id, country
FROM country
WHERE country IN ("Afghanistan", "Bangladesh", "China");


-- 3a) Create "description" column in the table "actor"
ALTER TABLE actor
ADD COLUMN description BLOB(15);
SELECT * FROM actor;

-- 3b) Delete the column "description"
ALTER TABLE actor
DROP COLUMN description;
SELECT * FROM actor;


-- 4a) List: last names of actors + # of how many actors have that last name
SELECT last_name, COUNT(last_name) as name_count
FROM actor
GROUP BY last_name;

-- 4b) List: last names of actors + # of how many actors have that last name, shared by at least 2 actors
SELECT last_name, COUNT(last_name) as name_count
FROM actor
GROUP BY last_name
HAVING name_count > 1;

-- 4c) Change all "GROUCHO WILLIAMS" in "actor" table to "HARPO WILLIAMS"
UPDATE actor
SET first_name = "HARPO", last_name = "WILLIAMS"
WHERE first_name = "GROUCHO" AND last_name = "WILLIAMS";
-- Check to see if it worked
SELECT * FROM actor
WHERE first_name = "HARPO";

-- 4d) Reverse 4c, change all "HARPO" to "GROUCHO"
UPDATE actor
SET first_name = "GROUCHO"
WHERE first_name = "HARPO";
-- Check to see if it worked
SELECT * FROM actor
WHERE first_name = "GROUCHO";


-- 5a) Re-Create the Address table
SHOW CREATE TABLE address;

CREATE TABLE address (
	address_id SMALLINT(5) unsigned NOT NULL AUTO_INCREMENT,
    address VARCHAR(50) NOT NULL,
    address2 VARCHAR(50) DEFAULT NULL,
    district VARCHAR(20) NOT NULL,
    city_id SMALLINT(5) unsigned NOT NULL,
    postal_code VARCHAR(10) DEFAULT NULL,
    phone VARCHAR(20) NOT NULL,
    location GEOMETRY NOT NULL,
    last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (address_id),
    KEY idx_fk_city_id (city_id),
    SPATIAL KEY idx_location (location),
    CONSTRAINT fk_address_city FOREIGN KEY (city_id) REFERENCES city (city_id) ON UPDATE CASCADE
)
ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8;
    

-- 6a) JOIN "staff" & "address" tables to display staff: first name, last name, address
SELECT staff.first_name, staff.last_name, address.address
FROM address
JOIN staff ON
staff.address_id=address.address_id;

-- 6b) JOIN "staff" & "payment" tables to display total amount rung up by each staff member in August 2005
SELECT staff.first_name, staff.last_name, sum(payment.amount) as august_totals
FROM staff
JOIN payment ON
staff.staff_id=payment.staff_id
GROUP BY staff.staff_id;

-- 6c) INNER JOIN "film_actor" & "film" to list: film & # of actors listed for film
SELECT film.title, COUNT(film_actor.actor_id) as film_actors
FROM film
INNER JOIN film_actor ON
film_actor.film_id=film.film_id
GROUP BY film.film_id;

-- 6d) How many copies of "Hunchback Impossible" exist in inventory?
SELECT film.title, COUNT(inventory.inventory_id) as inventory_copies
FROM film
JOIN inventory ON
film.film_id=inventory.film_id
GROUP BY film.film_id
HAVING film.title = "Hunchback Impossible";

-- 6e) JOIN "payment" & "customer" to list: total paid by each customer + list of customers alpha by last name
SELECT customer.first_name, customer.last_name, SUM(payment.amount) as total_paid
FROM customer
JOIN payment ON
customer.customer_id=payment.customer_id
GROUP BY customer.customer_id
ORDER BY customer.last_name;


-- 7a) Display the following: titles of movies starting with K and Q + language must be English
SELECT title
FROM film
WHERE language_id IN
	(
     SELECT language_id
     FROM language
     WHERE name = "English"
     )
AND title LIKE "Q%"
OR title LIKE "K%";

-- 7b) Display all actors who appeared in "Alone Trip"
SELECT first_name, last_name
FROM actor
WHERE actor_id IN
	(
	 SELECT actor_id
     FROM film_actor
     WHERE film_id IN
     (
      SELECT film_id
      FROM film
      WHERE title = "Alone Trip"
      )
	);

-- 7c) JOIN and retrieve the following from Canadian customers: names & emails
SELECT first_name, last_name, email
FROM customer
WHERE address_id IN
	(
     SELECT address_id
     FROM address
     WHERE city_id IN
     (
      SELECT city_id
      FROM city
      WHERE country_id IN
      (
       SELECT country_id
       FROM country
       WHERE country = "Canada"
       )
	)
);

-- 7d) Identify all movies categorized as "Family" films
SELECT title
FROM film
WHERE film_id IN
	(
     SELECT film_id
     FROM film_category
     WHERE category_id IN
     (
      SELECT category_id
      FROM category
      WHERE name = "Family"
      )
	);

-- 7e) Display the following: most frequently rented movies, in descending order.
SELECT film.title, COUNT(rental.rental_id) as rental_count
FROM film
JOIN (
	SELECT inventory_id, film_id
    FROM inventory
) inventory ON film.film_id=inventory.film_id
JOIN (
	SELECT rental_id, inventory_id
    FROM rental
) rental ON inventory.inventory_id=rental.inventory_id
GROUP BY film.film_id
ORDER BY rental_count DESC;

-- 7f) Show how much $$ each store brought in
-- I added in the address to help make it more clear which store was which. 
SELECT store.store_id, address.address, SUM(payment.amount) as store_total
FROM address
JOIN (
	SELECT  store_id, address_id
	FROM store
) store ON address.address_id=store.address_id
JOIN (
	SELECT staff_id, store_id
    FROM staff
) staff ON store.store_id=staff.store_id
JOIN (
	SELECT amount, staff_id
    FROM payment
) payment ON staff.staff_id=payment.staff_id
GROUP BY store.store_id;

-- 7g) Display the following for each store: store id, city, country
SELECT store.store_id, city.city, country
FROM country
JOIN (
	SELECT city_id, city, country_id
    FROM city
) city ON country.country_id=city.country_id
JOIN (
	SELECT address_id, city_id
    FROM address
) address ON city.city_id=address.city_id
JOIN (
	SELECT store_id, address_id
    FROM store
) store ON address.address_id=store.address_id;

-- 7h) List the top 5 genres in gross revenue, in descending order (use tables: category, film_category, inventory, payment, rental)
SELECT category.name, SUM(payment.amount) as gross_revenue
FROM payment
JOIN (
	SELECT rental_id, inventory_id
    FROM rental
) rental ON payment.rental_id=rental.rental_id
JOIN (
	SELECT film_id, inventory_id
    FROM inventory
) inventory ON rental.inventory_id=inventory.inventory_id
JOIN (
	SELECT film_id, category_id
    FROM film_category
) film_category ON inventory.film_id=film_category.film_id
JOIN (
	SELECT name, category_id
    FROM category
) category ON film_category.category_id=category.category_id
GROUP BY category.category_id
ORDER BY gross_revenue DESC
LIMIT 5;


-- 8a) Create a view of the Top 5 Genres
CREATE VIEW top5genres AS 
SELECT category.name, SUM(payment.amount) as gross_revenue
FROM payment
JOIN (
	SELECT rental_id, inventory_id
    FROM rental
) rental ON payment.rental_id=rental.rental_id
JOIN (
	SELECT film_id, inventory_id
    FROM inventory
) inventory ON rental.inventory_id=inventory.inventory_id
JOIN (
	SELECT film_id, category_id
    FROM film_category
) film_category ON inventory.film_id=film_category.film_id
JOIN (
	SELECT name, category_id
    FROM category
) category ON film_category.category_id=category.category_id
GROUP BY category.category_id
ORDER BY gross_revenue DESC
LIMIT 5;

-- 8b) Display the view from 8a
SELECT * FROM top5genres;

-- 8c) 
DROP VIEW top5genres;
