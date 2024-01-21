/*1.How many times does the average user post?*/


with average_u_p as
(select user_id, avg(id) as avg_user_post
from photos
group by user_id)
select * from average_u_p;

/*2.Find the top 5 most used hashtags.*/
select t.tag_name, count(pt.tag_id) as most_used
from photo_tags pt join tags t 
on pt.tag_id = t.id
group by t.tag_name
order by count(pt.tag_id) desc
limit 5;

/*3.Find users who have liked every single photo on the site.*/
select id, username
from users
where id In 
(select l.user_id from likes l right join photos p
 on l.photo_id = p.id
 where l.user_id = p.user_id
 );
 

/*4.Retrieve a list of users along with their usernames and the rank of their account creation,
 ordered by the creation date in ascending order.*/
select id, username,rank() over(order by created_at asc) as rank_account
from users;


/*5.List the comments made on photos with their comment texts, photo URLs, 
and usernames of users who posted the comments. Include the comment count for each photo */
select c.comment_text, p.image_url, u.username, count(c.photo_id) comment_count_each_photo
from comments c join photos p join users u
on c.photo_id = p.id and p.user_id = u.id
group by u.username;

select c.comment_text, p.image_url, u.username, count(c.id) comment_count_each_photo
from comments c join photos p join users u
on c.photo_id = p.id and p.user_id = u.id
group by u.username;

/*6.For each tag, show the tag name and the number of photos associated with that tag. 
Rank the tags by the number of photos in descending order.*/
select t.id, t.tag_name, count(pt.photo_id) no_of_photos, 
row_number() over(order by count(pt.photo_id) desc) rk_tags
from tags t join photo_tags pt
on t.id = pt.tag_id
group by t.id;

/*7.List the usernames of users who have posted photos along with the count of photos they have posted.
 Rank them by the number of photos in descending order.*/
select u.id, u.username, count(p.user_id) count_of_photos,
dense_rank() over(order by count(p.user_id) desc) rk_by_no_of_photos
from users u join photos p 
on u.id = p.user_id
group by u.id;

/*8.Display the username of each user along with the creation date of their first posted photo and
 the creation date of their next posted photo.*/
select p.user_id, u.username, p.created_at,
lead(p.created_at) over(partition by p.user_id) date_of_next_photo
 from users u join photos p 
 on u.id = p.user_id


/*9.For each comment, show the comment text, the username of the commenter, and the comment text
 of the previous comment made on the same photo.*/
select c.photo_id, c.comment_text, u.username, 
lag(c.comment_text) over(partition by photo_id) as pre_comm_on_same_photo 
from comments c join users u 
on c.user_id = u.id ;

/*10.Show the username of each user along with the number of photos they have posted and the number
 of photos posted by the user before them and after them, based on the creation date.*/
 select p.user_id, u.username, count(p.id) as no_of_photos,
 lag(count(p.id)) over(order by u.created_at) as before_photos,
 lead(count(p.id)) over(order by u.created_at) as after_photos
 from user u inner join photos p
 on u.id = p.user_id
 group by p.user_id, u.username;