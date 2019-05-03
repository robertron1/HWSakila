-- 1
USE sakila;
SELECT * FROM actor;
SELECT first_name, last_name FROM actor;
SELECT CONCAT(first_name, ' ', last_name) as 'Actor Name' FROM actor;
-- 2a
SELECT actor_id, first_name, last_name FROM actor
WHERE first_name = 'Joe';
-- 2b Find all actors whose last name contain the letters GEN:
SELECT actor_id, first_name, last_name FROM actor
WHERE last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT actor_id, first_name, last_name FROM actor WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:

SELECT country_id, country FROM country WHERE country IN ('Afghanistan' , 'Bangladesh' , 'China');
-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, so create a column in the table actor named description and use the data type BLOB
-- ALTER TABLE actor 
-- ADD COLUMN description BLOB;
-- 3B
-- ALTER TABLE actor 
-- DROP COLUMN description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(*) as num_actors
FROM actor 
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(*) as num_actors
FROM actor GROUP BY last_name 
HAVING count(*) > 1;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor 
SET first_name = 'HARPO', last_name = 'WILLIAMS' 
WHERE last_name = 'WILLIAMS' and first_name = 'GROUCHO';
select * from actor where last_name = 'WILLIAMS' and first_name = 'GROUCHO';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
SET SQL_SAFE_UPDATES=0; 
UPDATE actor 
SET first_name = 'GROUCHO' 
WHERE first_name = 'HARPO';

SELECT * FROM actor 
WHERE first_name = 'GROUCHO';
SET SQL_SAFE_UPDATES=1;

-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE Table address;

-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT staff.first_name, staff.last_name, address.address
FROM staff JOIN address on staff.address_id = address.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT staff.first_name, staff.last_name,sum(payment.amount) as 'Total for August 2005 '
FROM staff 
JOIN payment on staff.staff_id = payment.staff_id and
payment.payment_date>='2005-08-01' and
payment.payment_date<='2005-08-31'
GROUP BY staff.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT film.title, count(*) as "Number of Actors" FROM film 
inner join film_actor ON film.film_id = film_actor.film_id
GROUP BY film.title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT film.title, count(*) as "Number of Copies" FROM film 
inner join inventory 
ON film.film_id = inventory.film_id
WHERE film.title = 'Hunchback Impossible';

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT customer.first_name,customer.last_name, sum(amount) as "Total Amount Paid"
FROM customer 
JOIN payment on customer.customer_id = payment.customer_id 
GROUP BY customer.customer_id;

-- 7A. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
Select title 
FROM film WHERE language_id IN
(
SELECT language_id 
FROM language 
WHERE name = 'English'
)
AND (title LIKE 'K%' or title like 'Q%');

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip
SELECT first_name,last_name FROM actor 
WHERE actor_id IN
(
SELECT actor_id 
fROM film_actor 
WHERE film_id IN
(
SELECT film_id 
FROM film 
WHERE title = 'Alone Trip'
));

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT first_name,last_name, email, country.country
FROM customer
JOIN address on address.address_id = customer.address_id
JOIN city on address.city_id=city.city_id
JOIN country on city.country_id = country.country_id
WHERE country = 'Canada';

-- 7D. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT title, category.NAME
FROM film
JOIN film_category on film.film_id = film_category.film_id
JOIN category on category.category_id = film_category.category_id
WHERE NAME = 'Family';

--  7e. Display the most frequently rented movies in descending order
SELECT title, COUNT(*) as Frequency FROM film
JOIN inventory on inventory.film_id = film.film_id
JOIN rental  ON rental.inventory_id = inventory.inventory_id
GROUP BY film.film_id
ORDER BY Frequency desc ;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT  staff.store_id, sum(amount) AS "Total Business($)" 
FROM payment 
JOIN staff on staff.staff_id = payment.staff_id
GROUP BY staff.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.

SELECT store_id,city.city,country.country FROM store
JOIN address on address.address_id = store.address_id
JOIN city on address.city_id=city.city_id
JOIN country on city.country_id = country.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT category.name as 'Top 5 Genres', SUM(payment.amount) AS 'Gross_Revenue'
FROM category
JOIN film_category on category.category_id = film_category.category_id
JOIN inventory on inventory.film_id = film_category.film_id
JOIN rental on inventory.inventory_id = rental.inventory_id
JOIN payment on payment.rental_id = rental.rental_id
GROUP BY category.name 
ORDER BY Gross_Revenue desc 
LIMIT 5;

-- 8a!! In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

CREATE VIEW top_five_genres AS 
SELECT category.NAMES AS 'Top_Five', sum(payment.amount) as 'Gross_Revenue'
FROM category
JOIN film_category on category.category_id = film_category.category_id
JOIN inventory on inventory.film_id = film_category.film_id
JOIN rental on inventory.inventory_id = rental.inventory_id
JOIN payment on payment.rental_id = rental.rental_id
GROUP BY category.name 
ORDER BY Gross_Revenue desc 
LIMIT 5;
-- 8B
SELECT * FROM top_five_genres;
-- 8C.
DROP view top_five_genres;
