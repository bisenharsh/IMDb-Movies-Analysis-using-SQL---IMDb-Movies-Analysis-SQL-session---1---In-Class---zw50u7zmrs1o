-- Segment 1: Database - Tables, Columns, Relationships
-- 1.What are the different tables in the database and how are they connected to each other in the database?
--     There are 6 different tables in the database movie_project those are director_mapping_imdb,genre_imdb,movies_imdb,names_imdb,ratings_imdb,role_mapping_imdb.
--    The tables are connected on movie_id and name_id with each other.
      
      
-- 2.Find the total number of rows in each table of the schema.
-- director_mapping_imdb table
      select count(*) from director_mapping;
--     3867 
-- genre_imdb table
      select count(*) from genre;
--     14662
-- movies_imdb table
      select count(*) from movies;
--     7997
-- names_imdb table
      select count(*) from names;
--      25735
-- rating_imdb table
      select count(*) from ratings;
--      7997
-- role_mapping_imdb table
      select count(*) from role_mapping_imdb;
--      15615
      
      
--  3.Identify which columns in the movie table have null values.
    select sum(case when id is null then 1 else 0 end) as id_null,
    sum(case when title is null then 1 else 0 end) as title_null,
    sum(case when year is null then 1 else 0 end) as year_null,
    sum(case when date_published is null then 1 else 0 end) as date_null,
    sum(case when duration is null then 1 else 0 end) as duration_null,
    sum(case when country is null then 1 else 0 end) as country_null,
    sum(case when worlwide_gross_income is null then 1 else 0 end) as income_null,
    sum(case when languages is null then 1 else 0 end) as languages_null,
    sum(case when production_company is null then 1 else 0 end) as production_null from movies;
    
-- id_null=0  
-- title_null=0 
-- year_null=0 
-- date_null=0
-- duration_null=0
-- country_null=20
-- income_null=3724
-- languages_null=194
-- production_null=528

-- Segment 2: Movie Release Trends
-- 1.Determine the total number of movies released each year and analyse the month-wise trend.
	  select year,count(id) as total_movies from movies
      group by year;
	  select year,substr(date_published,6,2) as month,count(id) as total_movies
      from movies
      group by year,month
      order by year,month;
-- 2.Calculate the number of movies produced in the USA or India in the year 2019.
	  select count(*) from movies
      where (country='USA' or country='INDIA') and year=2019;
      
      -- Segment 3: Production Statistics and Genre Analysis
--	1.Retrieve the unique list of genres present in the dataset.
	select distinct(genre) from genre;
--	2.Identify the genre with the highest number of movies produced overall.
	select * from(select genre,count(movie_id) as total_movies,row_number() over(order by count(movie_id) desc) as ranks from genre
    group by genre) a
    where ranks=1 ;
--	3.Determine the count of movies that belong to only one genre.
	select count(*) from (select count(*) from genre
    group by movie_id
    having count(genre)=1) as d ;
--  3289
--	4.Calculate the average duration of movies in each genre.
	select g.genre,avg(m.duration) from genre as g join movies as m
    on g.movie_id=m.id
    group by g.genre;
    
--	5.Find the rank of the 'thriller' genre among all genres in terms of the number of movies produced.
	select s.genre,s.ranks from (select genre,rank() over(order by count(genre) desc) as ranks from genre
    group by genre) as t
    where genre='Thriller';
    
    -- Segment 4: Ratings Analysis and Crew Members
--	1.Retrieve the minimum and maximum values in each column of the ratings table (except movie_id).
	  select max(avg_rating),min(avg_rating),
      max(total_votes),min(total_votes),
      max(median_rating),min(median_rating)
      from rating;
      
-- 2.Identify the top 10 movies based on average rating.
	  select * from(select m.title,r.avg_rating,row_number() over(order by r.avg_rating desc) as ranks from rating r
      join movies m on r.movie_id=m.id)s
      where ranks<=10;
      
      
--	3.Summarise the ratings table based on movie counts by median ratings.
	  select median_rating,count(movie_id)
      from rating
      group by median_rating
      order by median_rating;
      
--	4.Identify the production house that has produced the most number of hit movies (average rating > 8).
	select * from (select production_company, count(id) as movie_count,
	row_number() over (order by count(id) desc) as ranks from movies
	left join rating on movie_id=id
	where avg_rating>8 and production_company!=''
	group by production_company) a where ranks=1;
--	5.Determine the number of movies released in each genre during March 2017 in the USA with more than 1,000 votes.
	 select genre,count(id) as total_movies from movies
     left join genre g on g.movie_id=id
     left join rating r on r.movie_id=id
     where total_votes>1000 and substr(date_published,6,2)='03' and year=2017
     and country='USA'
     group by genre
     order by genre;
--	6.Retrieve movies of each genre starting with the word 'The' and having an average rating > 8.
	  select genre,title,avg_rating
      from movies m left join genre g on m.id=g.movie_id
      left join rating r on m.id=r.movie_id
      where title like 'The%'
      and avg_rating>8
      order by genre;
      
      -- Segment 5: Crew Analysis
--	1.Identify the columns in the names table that have null values.
	  select sum(case when id is null then 1 else 0 end) as id_nulls,
sum(case when name is null then 1 else 0 end) as name_nulls,
sum(case when height is null then 1 else 0 end) as height_nulls,
sum(case when date_of_birth is null then 1 else 0 end) as date_of_birth_nulls,
sum(case when known_for_movies is null then 1 else 0 end) as known_for_movies_nulls
from names;
--	2.Determine the top three directors in the top three genres with movies having an average rating > 8.
	  with cte as (select genre from (select genre,rank() over(order by count(g.movie_id) desc) as ranks
      from genre g left join rating r on g.movie_id=r.movie_id
      where avg_rating>8
      group by genre) a
      where ranks<=3),
      cte2 as (select name,genre,count(m.id) as total_movie,row_number() over(partition by genre order by count(m.id) desc) as director_rank
      from movies m
	  left join genre g on m.id=g.movie_id
	  left join director_mapping d on d.movie_id=m.id
	  left join names n on n.id=d.name_id
      where name is not null
      group by genre,name,n.id
      )
     select * from cte2 where genre in (select genre from cte) 
     and director_rank<=3
     --	3.Find the top two actors whose movies have a median rating >= 8.
     
     select * from (select name,n.id,count(m.id) as movie_count,row_number() over(order by count(m.id) desc)as ranks from names n left join role_mapping r on
      (n.id=r.name_id)
      left join rating ri on r.movie_id=ri.movie_id
      left join movies m on m.id=r.movie_id
      where category = 'actor' and median_rating>=8
      group by n.id,n.name) s
      where ranks<=2;
      
      
--	4.Identify the top three production houses based on the number of votes received by their movies.
	 with cte as (select production_company,sum(total_votes) as total_vote from movies m 
      left join ratings r on m.id=r.movie_id
      group by production_company
      order by total_vote desc),
	cte2 as (select *,row_number() over(order by total_vote desc)as ranks from cte)
      (select * from cte2 where ranks<=3);      
      
--	5.Rank actors based on their average ratings in Indian movies released in India.
	  select name,avg(avg_rating) as avg_ratings,row_number() over(order by avg(avg_rating) desc) as ranks 
      from movies m left join rating r on m.id=r.movie_id
      left join role_mapping rm on r.movie_id=rm.movie_id
      left join names n on rm.name_id=n.id
      where category='actor' and country='India'
      group by n.id,n.name;
--	6.Identify the top five actresses in Hindi movies released in India based on their average ratings.
     select * from (select name,avg(avg_rating) as avg_ratings,row_number() over(order by avg(avg_rating) desc) as ranks from 
	  movies m left join rating r on m.id=r.movie_id
	 left join role_mapping rm on m.id=rm.movie_id
	 left join names n on rm.name_id=n.id
	 where category='actress' and country='India' and languages='hindi'
     group by n.id,n.name) k
	 where ranks<=5;
     --     Segment 6: Broader Understanding of Data
--	1.Classify thriller movies based on average ratings into different categories.
	  select title,avg_rating,case when avg_rating>8 then 'Hit Movie'
      when avg_rating<=4 then 'Flop Movie' else 'Avg Movie' end as category
      from movies m left join rating r on m.id=r.movie_id
      left join genre g on m.id=g.movie_id
      where genre='Thriller';
      
-- 2.analyse the genre-wise running total and moving average of the average movie duration.
	  select id,genre,duration,sum(duration) over(partition by genre order by id) as running_total,
      avg(duration) over(partition by genre order by id) as avg_duration from movies m
      left join genre g on m.id=g.movie_id;
-- 3.Identify the five highest-grossing movies of each year that belong to the top three genres.
	 with cte as(select genre from (select genre,row_number() over(order by count(movie_id) desc) as ranks
     from genre
	 group by genre) a where ranks<=3),
     cte2 as (select * from(select title,genre,concat('$ ',worlwide_gross_income) as gross_income,year,row_number() over(partition by year order by worlwide_gross_income desc ) as top_movies
     from movies m left join genre g on m.id=g.movie_id
     where genre in (select genre from cte)
     ) b 
     )
      (select * from cte2 where top_movies<=5);
--	4.Determine the top two production houses that have produced the highest number of hits among multilingual movies.
	  select * from (select production_company,count(id) total_hits,row_number() over(order by count(id) desc) as ranks
      from movies
      where languages like '%,%' and production_company !=''
      group by production_company)a
      where ranks<=2;
-- 5.Identify the top three actresses based on the number of Super Hit movies (average rating > 8) in the drama genre.
	  select* from (select name,count(m.id) as total_movie,avg(avg_rating) as rating ,row_number() over(order by (count(m.id)) desc) as ranks
      from  movies m left join rating r on m.id=r.movie_id
      left join role_mapping rm on m.id=rm.movie_id
      left join names n on n.id=rm.name_id
      where category='actress' and avg_rating>8
      group by n.id,name) a
      where ranks<=3 ;
      
-- 6.Retrieve details for the top nine directors based on the number of movies, including average inter-movie duration, ratings, and more.
	 select * from (select name,n.id,count(m.id) as total_movies,avg(avg_rating),avg(duration),row_number() over(order by count(m.id) desc,avg(avg_rating) desc,avg(duration)desc) as ranks
      from movies m left join director_mapping dm on m.id=dm.movie_id
      left join names n on dm.name_id=n.id
      left join rating r on m.id=r.movie_id
      where name is not null
      group by name,n.id) a
      where ranks <=9;
      -- Segment 7: Recommendations
-- Based on the analysis, provide recommendations for the types of content Bolly movies should focus on producing.
-- Bolly movies being a reputed production house in hindi cinema decided to extend its work globally 
-- should focus on following aspects made after analysing the data of the movies in the global arena.
-- 1.The total number of movies released each year are somewhere around 2000-3000 in decreasing order
-- in the last 3 years.So the less the number of movies produced every year the best the quality should be.
-- 2. There are only 887 movies produced in 2019 in India and USA,so if bolly movies cathces its market in 
-- USA it will be of great profit.
-- 3.There are total of 13 genre on which movies are produced worldwide,those are:-
-- Thriller,Fantasy,Drama,Comedy,Horror,Romance,Family,Adventure,Sci-Fi,Action,Mystery,Crime,
-- 4.Among all the genre Drama produced the maximum movies with the count of 4285,so the competition 
-- in drama is much high than that with other genres.
-- 5.The top 3 genre are Drama,Comedy,Thriller.
-- 6.The average duration of the movies should lie between 100-112 minutes to match the international standards.
-- 7.The top 10 movies from the past years are:-
-- Love in Kilnerry,Kirket,Gini Helida Kathe,Runam,Fan,Android Kunjappan Version 5.25,Yeh Suhaagraat Impossible,
-- Safe,The Brighton Miracle,Shibu.
-- 8.There are total of 346 movies with median ratings of 10 where as with the median ratings among 7-9 lies 
-- thousands of movies.
-- 9.The top 3 directors in each genre are:
-- Comedy:Sam Liu,Jesse V. Johnson,Anthony Russo
-- Drama:Ksshitij Chaudhary,Luis Eduardo Reyes,Yûichi Fukuda
-- Genre:Steven Soderbergh,Tigmanshu Dhulia,Jean-Claude La Marre
-- Working with these directors will be more profitable for bolly movies.
-- 10.The top 2 actors to work with are Mammootty,Mohanlal.
-- 11.The top 3 competitors for bolly movies are:Marvel Studios,Twentieth Century Fox,Warner Bros.
-- 12.The top 5 movies of top 3 genres in different years are:-
-- 2017:The Fate of the Furious,Despicable Me 3,Jumanji: Welcome to the Jungle,Zhan lang II,Zhan lang II   
-- 2018:Bohemian Rhapsody,Venom,Mission: Impossible - Fallout,Deadpool 2,Ant-Man and the Wasp
-- 2019:Avengers: Endgame,The Lion King,Toy Story 4,Joker