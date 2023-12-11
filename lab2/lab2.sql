-- Active: 1702038603655@@mariadb.edu.liu.se@3306@matka448
/*
Lab 2 report Mattias Karlsson matka448 and Yousef Drgham youdr728
*/
source company_schema.sql;
source company_data.sql;

select * from jbemployee;

/*+------+--------------------+--------+---------+-----------+-----------+
| id   | name               | salary | manager | birthyear | startyear |
+------+--------------------+--------+---------+-----------+-----------+
|   10 | Ross, Stanley      |  15908 |     199 |      1927 |      1945 |
|   11 | Ross, Stuart       |  12067 |    NULL |      1931 |      1932 |
|   13 | Edwards, Peter     |   9000 |     199 |      1928 |      1958 |
|   26 | Thompson, Bob      |  13000 |     199 |      1930 |      1970 |
|   32 | Smythe, Carol      |   9050 |     199 |      1929 |      1967 |
|   33 | Hayes, Evelyn      |  10100 |     199 |      1931 |      1963 |
|   35 | Evans, Michael     |   5000 |      32 |      1952 |      1974 |
|   37 | Raveen, Lemont     |  11985 |      26 |      1950 |      1974 |
|   55 | James, Mary        |  12000 |     199 |      1920 |      1969 |
|   98 | Williams, Judy     |   9000 |     199 |      1935 |      1969 |
|  129 | Thomas, Tom        |  10000 |     199 |      1941 |      1962 |
|  157 | Jones, Tim         |  12000 |     199 |      1940 |      1960 |
|  199 | Bullock, J.D.      |  27000 |    NULL |      1920 |      1920 |
|  215 | Collins, Joanne    |   7000 |      10 |      1950 |      1971 |
|  430 | Brunet, Paul C.    |  17674 |     129 |      1938 |      1959 |
|  843 | Schmidt, Herman    |  11204 |      26 |      1936 |      1956 |
|  994 | Iwano, Masahiro    |  15641 |     129 |      1944 |      1970 |
| 1110 | Smith, Paul        |   6000 |      33 |      1952 |      1973 |
| 1330 | Onstad, Richard    |   8779 |      13 |      1952 |      1971 |
| 1523 | Zugnoni, Arthur A. |  19868 |     129 |      1928 |      1949 |
| 1639 | Choy, Wanda        |  11160 |      55 |      1947 |      1970 |
| 2398 | Wallace, Maggie J. |   7880 |      26 |      1940 |      1959 |
| 4901 | Bailey, Chas M.    |   8377 |      32 |      1956 |      1975 |
| 5119 | Bono, Sonny        |  13621 |      55 |      1939 |      1963 |
| 5219 | Schwarz, Jason B.  |  13374 |      33 |      1944 |      1959 |
+------+--------------------+--------+---------+-----------+-----------+
25 rows in set (0.00 sec)*/

select name from jbdept order by name asc;

/*+------------------+
| name             |
+------------------+
| Bargain          |
| Book             |
| Candy            |
| Children's       |
| Children's       |
| Furniture        |
| Giftwrap         |
| Jewelry          |
| Junior Miss      |
| Junior's         |
| Linens           |
| Major Appliances |
| Men's            |
| Sportswear       |
| Stationary       |
| Toys             |
| Women's          |
| Women's          |
| Women's          |
+------------------+
19 rows in set (0.00 sec)*/

select * from jbparts where qoh=0;

/*+----+-------------------+-------+--------+------+
| id | name              | color | weight | qoh  |
+----+-------------------+-------+--------+------+
| 11 | card reader       | gray  |    327 |    0 |
| 12 | card punch        | gray  |    427 |    0 |
| 13 | paper tape reader | black |    107 |    0 |
| 14 | paper tape punch  | black |    147 |    0 |
+----+-------------------+-------+--------+------+
4 rows in set (0.00 sec)*/

select * from jbemployee where salary<= 10000 and salary>= 9000;

/*+-----+----------------+--------+---------+-----------+-----------+
| id  | name           | salary | manager | birthyear | startyear |
+-----+----------------+--------+---------+-----------+-----------+
|  13 | Edwards, Peter |   9000 |     199 |      1928 |      1958 |
|  32 | Smythe, Carol  |   9050 |     199 |      1929 |      1967 |
|  98 | Williams, Judy |   9000 |     199 |      1935 |      1969 |
| 129 | Thomas, Tom    |  10000 |     199 |      1941 |      1962 |
+-----+----------------+--------+---------+-----------+-----------+
4 rows in set (0.00 sec)*/

select name, startyear-birthyear from jbemployee;

/*+--------------------+---------------------+
| name               | startyear-birthyear |
+--------------------+---------------------+
| Ross, Stanley      |                  18 |
| Ross, Stuart       |                   1 |
| Edwards, Peter     |                  30 |
| Thompson, Bob      |                  40 |
| Smythe, Carol      |                  38 |
| Hayes, Evelyn      |                  32 |
| Evans, Michael     |                  22 |
| Raveen, Lemont     |                  24 |
| James, Mary        |                  49 |
| Williams, Judy     |                  34 |
| Thomas, Tom        |                  21 |
| Jones, Tim         |                  20 |
| Bullock, J.D.      |                   0 |
| Collins, Joanne    |                  21 |
| Brunet, Paul C.    |                  21 |
| Schmidt, Herman    |                  20 |
| Iwano, Masahiro    |                  26 |
| Smith, Paul        |                  21 |
| Onstad, Richard    |                  19 |
| Zugnoni, Arthur A. |                  21 |
| Choy, Wanda        |                  23 |
| Wallace, Maggie J. |                  19 |
| Bailey, Chas M.    |                  19 |
| Bono, Sonny        |                  24 |
| Schwarz, Jason B.  |                  15 |
+--------------------+---------------------+
25 rows in set (0.00 sec)*/

select * from jbemployee where substring_index(name,",",1) like N'%son';

/*+----+---------------+--------+---------+-----------+-----------+
| id | name          | salary | manager | birthyear | startyear |
+----+---------------+--------+---------+-----------+-----------+
| 26 | Thompson, Bob |  13000 |     199 |      1930 |      1970 |
+----+---------------+--------+---------+-----------+-----------+
1 row in set (0.01 sec)*/

select * from jbitem where supplier = (select id from jbsupplier where name="Fisher-Price");

/*+-----+-----------------+------+-------+------+----------+
| id  | name            | dept | price | qoh  | supplier |
+-----+-----------------+------+-------+------+----------+
|  43 | Maze            |   49 |   325 |  200 |       89 |
| 107 | The 'Feel' Book |   35 |   225 |  225 |       89 |
| 119 | Squeeze Ball    |   49 |   250 |  400 |       89 |
+-----+-----------------+------+-------+------+----------+
3 rows in set (0.00 sec)*/

select * from jbitem inner join jbsupplier on jbsupplier.id=jbitem.supplier and jbsupplier.name="Fisher-Price";

/*+-----+-----------------+------+-------+------+----------+----+--------------+------+
| id  | name            | dept | price | qoh  | supplier | id | name         | city |
+-----+-----------------+------+-------+------+----------+----+--------------+------+
|  43 | Maze            |   49 |   325 |  200 |       89 | 89 | Fisher-Price |   21 |
| 107 | The 'Feel' Book |   35 |   225 |  225 |       89 | 89 | Fisher-Price |   21 |
| 119 | Squeeze Ball    |   49 |   250 |  400 |       89 | 89 | Fisher-Price |   21 |
+-----+-----------------+------+-------+------+----------+----+--------------+------+
3 rows in set (0.00 sec)*/

select * from jbcity where id in (select city from jbsupplier);

/*+-----+----------------+-------+
| id  | name           | state |
+-----+----------------+-------+
|  10 | Amherst        | Mass  |
|  21 | Boston         | Mass  |
| 100 | New York       | NY    |
| 106 | White Plains   | Neb   |
| 118 | Hickville      | Okla  |
| 303 | Atlanta        | Ga    |
| 537 | Madison        | Wisc  |
| 609 | Paxton         | Ill   |
| 752 | Dallas         | Tex   |
| 802 | Denver         | Colo  |
| 841 | Salt Lake City | Utah  |
| 900 | Los Angeles    | Calif |
| 921 | San Diego      | Calif |
| 941 | San Francisco  | Calif |
| 981 | Seattle        | Wash  |
+-----+----------------+-------+
15 rows in set (0.00 sec)*/

select name, color from jbparts where weight > (select weight from jbparts where name="card reader");

/*+--------------+--------+
| name         | color  |
+--------------+--------+
| disk drive   | black  |
| tape drive   | black  |
| line printer | yellow |
| card punch   | gray   |
+--------------+--------+
4 rows in set (0.00 sec)*/

select a.name, a.color from jbparts as a inner join jbparts as b on b.name="card reader" where a.weight > b.weight;

/*+--------------+--------+
| name         | color  |
+--------------+--------+
| disk drive   | black  |
| tape drive   | black  |
| line printer | yellow |
| card punch   | gray   |
+--------------+--------+
4 rows in set (0.00 sec)*/

select avg(weight) from jbparts where color="black";

/*+-------------+
| avg(weight) |
+-------------+
|    347.2500 |
+-------------+
1 row in set (0.00 sec)*/

select supp.name, sum(quan*weight) as weight_total from
(select id, name, part, quan from jbsupply inner join
(select id, name from jbsupplier where city in
(select id from jbcity where state like "Mass")) as a on supplier = id)
as supp inner join jbparts on part = jbparts.id group by supp.id;

/*+--------------+--------------+
| name         | weight_total |
+--------------+--------------+
| Fisher-Price |      1135000 |
| DEC          |         3120 |
+--------------+--------------+
2 rows in set (0.00 sec)*/


drop table item_new;
create table item_new(
id int,
name varchar(64),
dept int,
price int,
qoh int,
supplier int,
constraint pk_item_new primary key (id),
constraint fk_dept foreign key (dept) references jbdept(id),
constraint fk_supplier foreign key (supplier) references jbsupplier(id)
);

insert into item_new (select * from jbitem where price < (select avg(price) from jbitem));
select * from item_new;

/*+-----+-----------------+------+-------+------+----------+
| id  | name            | dept | price | qoh  | supplier |
+-----+-----------------+------+-------+------+----------+
|  11 | Wash Cloth      |    1 |    75 |  575 |      213 |
|  19 | Bellbottoms     |   43 |   450 |  600 |       33 |
|  21 | ABC Blocks      |    1 |   198 |  405 |      125 |
|  23 | 1 lb Box        |   10 |   215 |  100 |       42 |
|  25 | 2 lb Box, Mix   |   10 |   450 |   75 |       42 |
|  26 | Earrings        |   14 |  1000 |   20 |      199 |
|  43 | Maze            |   49 |   325 |  200 |       89 |
| 106 | Clock Book      |   49 |   198 |  150 |      125 |
| 107 | The 'Feel' Book |   35 |   225 |  225 |       89 |
| 118 | Towels, Bath    |   26 |   250 | 1000 |      213 |
| 119 | Squeeze Ball    |   49 |   250 |  400 |       89 |
| 120 | Twin Sheet      |   26 |   800 |  750 |      213 |
| 165 | Jean            |   65 |   825 |  500 |       33 |
| 258 | Shirt           |   58 |   650 | 1200 |       33 |
+-----+-----------------+------+-------+------+----------+
14 rows in set (0.01 sec)*/

drop view item_view;
create view item_view as select * from item_new;
select * from item_view;

/*+-----+-----------------+------+-------+------+----------+
| id  | name            | dept | price | qoh  | supplier |
+-----+-----------------+------+-------+------+----------+
|  11 | Wash Cloth      |    1 |    75 |  575 |      213 |
|  19 | Bellbottoms     |   43 |   450 |  600 |       33 |
|  21 | ABC Blocks      |    1 |   198 |  405 |      125 |
|  23 | 1 lb Box        |   10 |   215 |  100 |       42 |
|  25 | 2 lb Box, Mix   |   10 |   450 |   75 |       42 |
|  26 | Earrings        |   14 |  1000 |   20 |      199 |
|  43 | Maze            |   49 |   325 |  200 |       89 |
| 106 | Clock Book      |   49 |   198 |  150 |      125 |
| 107 | The 'Feel' Book |   35 |   225 |  225 |       89 |
| 118 | Towels, Bath    |   26 |   250 | 1000 |      213 |
| 119 | Squeeze Ball    |   49 |   250 |  400 |       89 |
| 120 | Twin Sheet      |   26 |   800 |  750 |      213 |
| 165 | Jean            |   65 |   825 |  500 |       33 |
| 258 | Shirt           |   58 |   650 | 1200 |       33 |
+-----+-----------------+------+-------+------+----------+
14 rows in set (0.00 sec)*/

drop view debit_view;
create view debit_view as select debit, sum(price*quantity) as cost_total from jbsale, jbitem where id=item group by debit;
select * from debit_view;

/*+--------+------------+
| debit  | cost_total |
+--------+------------+
| 100581 |       2050 |
| 100582 |       1000 |
| 100586 |      13446 |
| 100592 |        650 |
| 100593 |        430 |
| 100594 |       3295 |
+--------+------------+
6 rows in set (0.00 sec)*/

drop view debit_view;
create view debit_view as select debit, sum(price*quantity) as cost_total from jbsale left outer join jbitem on item=id group by debit;
select * from debit_view;

/* left outer join is used since it is important that we have every sale in the created view.

+--------+------------+
| debit  | cost_total |
+--------+------------+
| 100581 |       2050 |
| 100582 |       1000 |
| 100586 |      13446 |
| 100592 |        650 |
| 100593 |        430 |
| 100594 |       3295 |
+--------+------------+
6 rows in set (0.00 sec)*/

create view city_id as (select id from jbcity where name like "Los Angeles");
create view supplier_id as (select id from jbsupplier where city = (select * from city_id));

delete from jbsupply where supplier = (select * from supplier_id);
delete from jbsale where item in (select id from jbitem where supplier = (select * from supplier_id)); 
delete from jbitem where supplier = (select * from supplier_id);
delete from item_new where supplier = (select * from supplier_id);
delete from jbsupplier where city = (select * from city_id);

select * from jbsupplier;

drop view city_id;
drop view supplier_id;

/*
We created two new views so we can save the city_id and supplier_id to easily delete the tuples
where the citys supplier is used. Then we started deleting the references from the ground up. 

jbsupply uses the supplier so remove all supply that uses the los angeles supplier
jbsale uses items that are supplied by supplier in los angeles so remove the sales
jbitem uses the supplier so remove all suppliers from los angeles
item_new is our new table which also has supplier

After removing all the reference tuples we can now remove the supplier from jbsupplier

+-----+--------------+------+
| id  | name         | city |
+-----+--------------+------+
|   5 | Amdahl       |  921 |
|  15 | White Stag   |  106 |
|  20 | Wormley      |  118 |
|  33 | Levi-Strauss |  941 |
|  42 | Whitman's    |  802 |
|  62 | Data General |  303 |
|  67 | Edger        |  841 |
|  89 | Fisher-Price |   21 |
| 122 | White Paper  |  981 |
| 125 | Playskool    |  752 |
| 213 | Cannon       |  303 |
| 241 | IBM          |  100 |
| 440 | Spooley      |  609 |
| 475 | DEC          |   10 |
| 999 | A E Neumann  |  537 |
+-----+--------------+------+
15 rows in set (0.00 sec)*/



drop view jbsale_supply;
create view jbsale_supply(supplier, item, quantity) as 
select jbsupplier.name, jbitem.name, jbsale.quantity
from jbsupplier
inner join jbitem on jbsupplier.id=jbitem.supplier 
left outer join jbsale on jbsale.item=jbitem.id;

select supplier, sum(quantity) as sum from jbsale_supply group by supplier;

/*
+--------------+------+
| supplier     | sum  |
+--------------+------+
| Cannon       |    6 |
| Fisher-Price | NULL |
| Koret        |    1 |
| Levi-Strauss |    1 |
| Playskool    |    2 |
| White Stag   |    4 |
| Whitman's    |    2 |
+--------------+------+
7 rows in set (0.00 sec)
*/