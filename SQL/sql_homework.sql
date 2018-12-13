use sakila;

-- SELECT * FROM sakila.actor;

-- 1a  Display the first and last names of all actors from the table `actor`.
select first_name, last_name 
from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.
select concat(first_name,' ', last_name) AS Actor_Name 
from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select actor_ID, first_name, last_name 
from actor
where first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters `GEN`:
select *
from actor
where last_name like '%GEN%';

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:
select *
from actor
where last_name like '%LI%'
order by last_name, first_name;

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country 
from country
where country in ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. 
-- You don't think you will be performing queries on a description, so create a column in 
-- the table `actor` named `description` and use the data type `BLOB` 
-- (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).
alter table actor
add description blob;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.
alter table actor
drop column description;

-- 4a. List the last names of actors, as well as how many actors have that last name.
select  last_name, count(*)
from actor
group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, 
-- but only for names that are shared by at least two actors
select last_name, count(*)
from actor
group by last_name
having count(*) >= 2;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. 
-- Write a query to fix the record.
update actor
set first_name = 'HARPO'
where actor_id = 172;

select *
from actor
where actor_id = 172;

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. 
-- It turns out that `GROUCHO` was the correct name after all! In a single query, 
-- if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.
select *
from actor
where first_name = 'HARPO';

update actor
set first_name = 'GROUCHO'
where actor_id = 172;

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
describe address;
show create table address;

-- Hint: [https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html](https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html)

-- 6a. Use `JOIN` to display the first and last names, as well as the address, 
-- of each staff member. Use the tables `staff` and `address`:

select first_name, last_name, address
from staff
inner join address on staff.address_id = address.address_id;

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. 
-- Use tables `staff` and `payment`.

select first_name, last_name, payment.staff_id, sum(amount)
from staff
inner join payment on staff.staff_id = payment.staff_id
where payment_date like '2005-08%'
group by payment.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. 
-- Use tables `film_actor` and `film`. Use inner join.

select film.film_id, title, count(actor_id)
from film
inner join film_actor on film.film_id = film_actor.film_id
group by film_actor.film_id;


-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?

select inventory.film_id, title, count(*)
from film
inner join inventory on film.film_id = inventory.film_id
where title = 'Hunchback Impossible'
group by film_id;

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. 
-- List the customers alphabetically by last name:

 -- ![Total amount paid](Images/total_payment.png)

select first_name, last_name, sum(amount)
from customer
inner join payment on customer.customer_id = payment.customer_id
group by payment.customer_id
order by last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters `K` and `Q` have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.
select * 
from film
where language_id = (select language_id from language where name = 'English')
and (title like 'K%') or (title like 'Q%');

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.

select first_name, last_name 
from actor 
where actor_id 
in
(select actor_id from film_actor where film_id = 
(select film_id from film where title = 'Alone Trip'));

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.

select customer.last_name, customer.first_name, customer.email 
from customer 
inner join customer_list on customer.customer_id = customer_list.ID 
where customer_list.country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as _family_ films.

select title 
from film
where film_id in 
(select film_id from film_category where category_id in
(select category_id from category where name = 'Family'));

-- 7e. Display the most frequently rented movies in descending order.

select film.title, count(*) as 'rental_count' 
from film, inventory, rental 
where film.film_id = inventory.film_id 
and rental.inventory_id = inventory.inventory_id 
group by inventory.film_id 
order by count(*) desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.

select store.store_id, sum(payment.amount)
from store, staff, payment
where store.store_id = staff.store_id and staff.staff_id = payment.staff_id
group by store.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.

select store_id, city, country
from store
inner join address on store.address_id = address.address_id
inner join city on address.city_id = city.city_id
inner join country on city.country_id = country.country_id;

-- 7h. List the top five genres in gross revenue in descending order. 
-- (**Hint**: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

select category.name, sum(payment.amount) as gross_revenue 
from category 
inner join film_category on film_category.category_id = category.category_id 
inner join inventory on inventory.film_id = film_category.film_id 
inner join rental on rental.inventory_id = inventory.inventory_id 
inner join payment on payment.rental_id = rental.rental_id 
group by category.name 
order by gross_revenue desc
limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the 
-- Top five genres by gross revenue. Use the solution from the problem above to create a view. 
-- If you haven't solved 7h, you can substitute another query to create a view.

create view top_five_genres as
select category.name, sum(payment.amount) as gross_revenue 
from category 
inner join film_category on film_category.category_id = category.category_id 
inner join inventory on inventory.film_id = film_category.film_id 
inner join rental on rental.inventory_id = inventory.inventory_id 
inner join payment on payment.rental_id = rental.rental_id 
group by category.name 
order by gross_revenue desc
limit 5;

-- 8b. How would you display the view that you created in 8a?
select * 
from top_five_genres;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.
drop view top_five_genres;