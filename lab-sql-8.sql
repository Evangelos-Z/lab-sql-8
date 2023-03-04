use sakila;

# 1. Rank films by length (filter out the rows with nulls or zeros in length column). Select only columns title, length and rank in your output.

select title, length, dense_rank() over (order by length desc) as 'rank' from film		# dense_rank() makes more sense than rank() here, because it gives us info about the number of groups rather than the number of rows in a group
where length is not null and length > 0;

# 2. Rank films by length within the rating category (filter out the rows with nulls or zeros in length column). In your output, only select the columns title, length, rating and rank.

select title, length, rating, dense_rank() over (partition by rating order by length desc) as 'rank' from film		# same as above
where length is not null and length > 0;

# 3. How many films are there for each of the categories in the category table? Hint: Use appropriate join between the tables "category" and "film_category".

select C.category_id as category, C.name as category_name, count(N.film_id) as num_films 
from category as C
inner join film_category as N
on C.category_id = N.category_id
group by category
order by num_films desc;

# what interests us is the number of films per category, which means that we need to pick a table where category_id will be the primary key, in order to group by that key

# 4. Which actor has appeared in the most films? Hint: You can create a join between the tables "actor" and "film actor" and count the number of times an actor appears.

select count(distinct actor_id) from actor;		# actor ids
select count(distinct actor_id) from film_actor;		# actors and films they've played in
select count(distinct film_id) from film_actor;		# distinct films where actors in this the table have played

# --> in both tables actor_id is the primary key and has the same number of distinct values

select A.actor_id, A.first_name, A.last_name, count(distinct F.film_id) as appearances
from actor A
inner join film_actor F
on A.actor_id = F.actor_id
group by actor_id
order by appearances desc
limit 1;

# The answer is "Gina Degeneres"

# --> since the joined table also has the same number of rows, I could actually also join left or right without losing data or getting rows filled with nulls

select A.actor_id, A.first_name, A.last_name, count(distinct F.film_id) as appearances
from actor A
left join film_actor F
on A.actor_id = F.actor_id
where first_name is not null		# just to demonstrate that there aren't any rows filled with nulls
group by actor_id
order by appearances desc;

# 5. Which is the most active customer (the customer that has rented the most number of films)? Hint: Use appropriate join between the tables "customer" and "rental" and count the rental_id for each customer.

select C.customer_id, C.first_name, C.last_name, count(R.rental_id) as num_rentals
from customer C 
inner join rental R
on C.customer_id = R.customer_id		# customer_id in customer is the primary key, while in rental it is the foreign one
group by customer_id
order by num_rentals desc
limit 1;

# The answer is "Eleanor Hunt".

#Bonus: Which is the most rented film? (The answer is Bucket Brotherhood).
#This query might require using more than one join statement. Give it a try. We will talk about queries with multiple join statements later in the lessons.
#Hint: You can use join between three tables - "Film", "Inventory", and "Rental" and count the rental ids for each film.

select count(distinct film_id) from inventory;		# 958 distinct values
select count(distinct film_id) from film;		# 1000 distinct values

select F.film_id, F.title as film_title, count(R.rental_id) as num_rentals
from inventory I		# using inventory as a basis to avoid null cells
inner join film F
on I.film_id = F.film_id
inner join rental R 
on I.inventory_id = R.inventory_id		# joining with the up to now generated table on inventory_id bridges the gap between the tables film and rental and makes it possible to count rentals per film_id
group by film_id
order by num_rentals desc;

