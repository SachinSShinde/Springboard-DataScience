/* Welcome to the SQL mini project. For this project, you will use
Springboard' online SQL platform, which you can log into through the
following link:

https://sql.springboard.com/
Username: student
Password: learn_sql@springboard

The data you need is in the "country_club" database. This database
contains 3 tables:
    i) the "Bookings" table,
    ii) the "Facilities" table, and
    iii) the "Members" table.

Note that, if you need to, you can also download these tables locally.

In the mini project, you'll be asked a series of questions. You can
solve them using the platform, but for the final deliverable,
paste the code for each solution into this script, and upload it
to your GitHub.

Before starting with the questions, feel free to take your time,
exploring the data, and getting acquainted with the 3 tables. */



/* Q1: Some of the facilities charge a fee to members, but some do not.
Please list the names of the facilities that do. */
SELECT name
FROM  `Facilities` 
WHERE membercost > 0.0;


/* Q2: How many facilities do not charge a fee to members? */
SELECT COUNT( * ) 
FROM  `Facilities` 
WHERE membercost = 0.0;


/* Q3: How can you produce a list of facilities that charge a fee to members,
where the fee is less than 20% of the facility's monthly maintenance cost?
Return the facid, facility name, member cost, and monthly maintenance of the
facilities in question. */
SELECT facid
		,name
		,membercost
		,monthlymaintenance 
FROM `Facilities` 
WHERE membercost < (monthlymaintenance * 0.20);

/* Q4: How can you retrieve the details of facilities with ID 1 and 5?
Write the query without using the OR operator. */
SELECT * 
FROM `Facilities` 
WHERE facid IN (1,5);

/* Q5: How can you produce a list of facilities, with each labelled as
'cheap' or 'expensive', depending on if their monthly maintenance cost is
more than $100? Return the name and monthly maintenance of the facilities
in question. */
SELECT *
		,CASE WHEN monthlymaintenance > 100.00 THEN 'expensive' 
			ELSE 'cheap'
			END AS Label
FROM `Facilities` ;

/* Q6: You'd like to get the first and last name of the last member(s)
who signed up. Do not use the LIMIT clause for your solution. */
SELECT firstname
		,surname
FROM `Members` 
WHERE 1=1
AND joindate = (SELECT MAX(joindate) FROM Members);

/* Q7: How can you produce a list of all members who have used a tennis court?
Include in your output the name of the court, and the name of the member
formatted as a single column. Ensure no duplicate data, and order by
the member name. */

SELECT DISTINCT CONCAT(d.firstname, " ",d.surname) as Member_Name
		,c.Court_Name
		
FROM 
(SELECT a.facid
		,b.Court_Name
 		,a.memid
FROM `Bookings` a 
INNER JOIN (SELECT facid, name as Court_Name FROM `Facilities`
WHERE name LIKE 'Tennis Court%') b
ON a.facid = b.facid) c
INNER JOIN `Members` d
ON c.memid = d.memid
ORDER BY CONCAT(d.firstname,' ',d.surname) ;


/* Q8: How can you produce a list of bookings on the day of 2012-09-14 which
will cost the member (or guest) more than $30? Remember that guests have
different costs to members (the listed costs are per half-hour 'slot'), and
the guest user's ID is always 0. Include in your output the name of the
facility, the name of the member formatted as a single column, and the cost.
Order by descending cost, and do not use any subqueries. */
SELECT b.name AS facility_name
		,CONCAT( c.firstname,  ' ', c.surname ) AS Name
		,CASE WHEN a.memid = 0 THEN b.guestcost * a.slots
			ELSE b.membercost * a.slots
			END AS cost
FROM Bookings a
INNER JOIN Facilities b
	ON a.facid = b.facid
		AND DATE(a.starttime) =  '2012-09-14'
		AND (((a.memid = 0) AND (b.guestcost * a.slots >30))
		OR ((a.memid != 0) AND (b.membercost * a.slots >30)))
INNER JOIN Members c
	ON a.memid = c.memid
ORDER BY cost DESC;

/* Q9: This time, produce the same result as in Q8, but using a subquery. */

SELECT * 
FROM (
	SELECT b.name AS Facility_Name
			,CONCAT( c.firstname,  ' ', c.surname ) AS name
			,CASE WHEN a.memid = 0 THEN b.guestcost * a.slots
				ELSE b.membercost * a.slots
				END AS cost
	FROM Bookings a
	INNER JOIN Facilities b
		ON a.facid = b.facid
		AND DATE(a.starttime) =  '2012-09-14'
	INNER JOIN Members c 
		ON a.memid = c.memid
)d
WHERE d.cost >30
ORDER BY d.cost DESC;


/* Q10: Produce a list of facilities with a total revenue less than 1000.
The output of facility name and total revenue, sorted by revenue. Remember
that there's a different cost for guests and members! */
SELECT * 
FROM(

SELECT Facility_Name, SUM(COST) as REVENUE
FROM
(SELECT b.name as Facility_Name
		, CASE WHEN c.memid = 0 THEN a.slots * b.guestcost 
			ELSE a.slots * b.membercost
			END AS COST

FROM Bookings a
INNER JOIN Facilities b
ON a.facid = b.facid
INNER JOIN Members c
ON a.memid = c.memid) d
GROUP BY Facility_Name) e
WHERE e.REVENUE < 1000
ORDER BY REVENUE DESC;

