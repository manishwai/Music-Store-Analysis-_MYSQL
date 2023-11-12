use music_store_project;
show tables;
##1. Who is the senior most employee based on job level ?
select  concat( first_name, "-" ,last_name) from employee
order by levels asc
limit 1;

##2. Which countries have the most Invoices?
select billing_country , count( invoice_id) as count from invoice
group by billing_country
order by count desc
limit 1;


##3. What are top 3 values of total invoice?
select  *   from invoice
order by total desc
limit 3;


/*4. Which city has the best customers? 
We would like to throw a promotional Music Festival in the city we made the most money.
Write a query that returns one city that has the highest sum of invoice totals.
Return both the city name & sum of all invoice totals */
select billing_city as city  , round(sum(total),2) as total_sales from
invoice
group by city 
order by total_sales desc;

/*###5. Who is the best customer? 
The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money */
select * from invoice ;
select c.first_name as name , sum(i.total) as total_amount_spent 
from customer   c
join invoice  i 
on c.customer_id=i.customer_id
group by name 
order by total_amount_spent desc
limit 1;

###1. Write query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A
select * from genre;
select c.first_name , c.last_name , c.email 
from customer c 
join invoice i
on c.customer_id=i.customer_id
join invoice_line i_l
on i.invoice_id =i_l.invoice_line_id
join track t 
on i_l.track_id=t.track_id
join genre g 
on t.genre_id=g.genre_id
where g.name="Rock";

###2. Let's invite the artists who have written the most rock music in our dataset. Write a query that returns the Artist name and total track count of the top 10 rock bands
select a.name , a.artist_id ,count(a.artist_id) as rock_music_count 
from artist a 
join album al 
on a.artist_id=al.artist_id
join track t
on al.album_id=t.album_id
join genre g 
on t.genre_id=g.genre_id
where g.name ="rock"
group by a.name , a.artist_id
order by rock_music_count desc;

select * from track;

###3. Return all the track names that have a song length longer than the average song length. Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first
select name , milliseconds 
from track 
where milliseconds > (
	SELECT AVG(milliseconds) AS avg_track_length
	FROM track )
ORDER BY milliseconds DESC;

###1. Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent

select c.customer_id, c.first_name as customer_name  , a.name as artist_name  ,sum(i_l.unit_price*i_l.quantity) as total_spent
from customer c
join invoice i on c.customer_id = i.customer_id 
join invoice_line i_l on i.invoice_id =i_l.invoice_line_id
join track t on i_l.track_id=t.track_id
join album al on t.album_id=al.album_id
join artist a on al.artist_id=a.artist_id
group by c.customer_id ,  artist_name,customer_name
order by total_spent desc  ;

###1. Find how much amount spent by each customer on  top selling artists? Write a query to return customer name, artist name and total spent
WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY artist_id , artist_name
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;


###2. We want to find out the most popular music Genre for each country. We determine the
###most popular genre as the genre with the highest amount of purchases. Write a query
###that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres


WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1;

##3. Write a query that determines the customer that has spent the most on music for each
###country. Write a query that returns the country along with the top customer and how
###much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount


WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1