1. Для каждого этажа подсчитываем количество номеров разных типов и всего номеров на каждом этаже и на всех этажах

# 2022-12-02 23:20:10.947882
select
if(grouping(Floor), 'all floors', Floor) as `floor`,
if(grouping(`Class`), 'all classes', `Class`) as `class`,
count(*) from `Room` group by Floor, Class with rollup; 
+------------+-------------+----------+
| floor      | class       | count(*) |
+------------+-------------+----------+
| 1          | vip         | 1        |
| 1          | standart    | 2        |
| 1          | half vip    | 2        |
| 1          | all classes | 5        |
| 2          | vip         | 1        |
| 2          | standart    | 1        |
| 2          | half vip    | 3        |
| 2          | all classes | 5        |
| 3          | standart    | 2        |
| 3          | half vip    | 2        |
| 3          | all classes | 4        |
| 4          | vip         | 4        |
| 4          | half vip    | 1        |
| 4          | all classes | 5        |
| 5          | half vip    | 1        |
| 5          | all classes | 1        |
| all floors | all classes | 20       |
+------------+-------------+----------+
17 rows in set
Time: 0.021s

2. Для каждого этажа подсчитываем вместимость номеров разных типов и всего номеров на каждом этаже и на всех этажах

# 2022-12-02 23:20:21.679861
select
if(grouping(Floor), 'all floors', Floor) as `floor`,
if(grouping(`Class`), 'all classes', `Class`) as `class`,
sum(`Capacity`) from `Room` group by Floor, Class with rollup; 
+------------+-------------+-----------------+
| floor      | class       | sum(`Capacity`) |
+------------+-------------+-----------------+
| 1          | vip         | 1               |
| 1          | standart    | 2               |
| 1          | half vip    | 2               |
| 1          | all classes | 5               |
| 2          | vip         | 4               |
| 2          | standart    | 3               |
| 2          | half vip    | 6               |
| 2          | all classes | 13              |
| 3          | standart    | 5               |
| 3          | half vip    | 5               |
| 3          | all classes | 10              |
| 4          | vip         | 8               |
| 4          | half vip    | 1               |
| 4          | all classes | 9               |
| 5          | half vip    | 4               |
| 5          | all classes | 4               |
| all floors | all classes | 41              |
+------------+-------------+-----------------+
17 rows in set
Time: 0.032s

3. Для каждого типа номера всех номеров вместе подсчитываем, сколько на него потратили посетители

# 2022-12-02 23:28:02.893759
select if( grouping(r.`Class`), 'all classes', r.`Class` ) as class, sum( h.Price ) from Room r join HotelOrder h
using( room_id ) group by r.`Class` with rollup 
+-------------+----------------+
| class       | sum( h.Price ) |
+-------------+----------------+
| half vip    | 4309300        |
| standart    | 3253470        |
| vip         | 3732601        |
| all classes | 11295371       |
+-------------+----------------+
4 rows in set
Time: 0.013s

4. Для каждого типа номера на каждом этаже и для всех номеров вместе подсчитываем, сколько на них потратили посетители

# 2022-12-02 23:29:45.787439
select
if( grouping(r.`Class`), 'all classes', r.`Class` ) as `class`,
if( grouping(r.`Floor`), 'all floors', r.`Floor` ) as `floor`,
sum( h.Price ) from Room r join HotelOrder h
using( room_id ) group by r.`Class`, r.Floor with rollup
+-------------+------------+----------------+
| class       | floor      | sum( h.Price ) |
+-------------+------------+----------------+
| half vip    | 1          | 618724         |
| half vip    | 2          | 1863534        |
| half vip    | 3          | 1297785        |
| half vip    | 5          | 529257         |
| half vip    | all floors | 4309300        |
| standart    | 1          | 2067304        |
| standart    | 2          | 98620          |
| standart    | 3          | 1087546        |
| standart    | all floors | 3253470        |
| vip         | 1          | 1055384        |
| vip         | 2          | 650826         |
| vip         | 4          | 2026391        |
| vip         | all floors | 3732601        |
| all classes | all floors | 11295371       |
+-------------+------------+----------------+
14 rows in set
Time: 0.029s


5. Поменяли группировку относительно предыдущего варианта: для каждого этажа для каждого типа на этом этаже и для всех номеров вместе подсчитываем, сколько на них потратили посетители


# 2022-12-02 23:30:25.485687
select
if( grouping(r.`Class`), 'all classes', r.`Class` ) as `class`,
if( grouping(r.`Floor`), 'all floors', r.`Floor` ) as `floor`,
sum( h.Price ) from Room r join HotelOrder h
using( room_id ) group by r.Floor, r.`Class` with rollup
+-------------+------------+----------------+
| class       | floor      | sum( h.Price ) |
+-------------+------------+----------------+
| half vip    | 1          | 618724         |
| standart    | 1          | 2067304        |
| vip         | 1          | 1055384        |
| all classes | 1          | 3741412        |
| half vip    | 2          | 1863534        |
| standart    | 2          | 98620          |
| vip         | 2          | 650826         |
| all classes | 2          | 2612980        |
| half vip    | 3          | 1297785        |
| standart    | 3          | 1087546        |
| all classes | 3          | 2385331        |
| vip         | 4          | 2026391        |
| all classes | 4          | 2026391        |
| half vip    | 5          | 529257         |
| all classes | 5          | 529257         |
| all classes | all floors | 11295371       |
+-------------+------------+----------------+
16 rows in set
Time: 0.030s


6. Для каждой специальности и работника высчитываем сколько кто зарабатывает


# 2022-12-02 23:46:03.378926
select
if( grouping(pi.FullName), 'all employees', pi.FullName) as employee,
if( grouping(e.Speciality), 'all specialities', e.Speciality) as speciality,
sum( edi.Salary * edi.Rate ) as salary from
`PersonInfo` pi  join ( `EmployeeDetailedInfo` edi join `Employee` e
using( employee_id ) ) on edi.employee_id = pi.person_id
group by e.`Speciality`, pi.FullName with rollup
+----------------------+-------------------------------+----------------------+
| employee             | speciality                    | salary               |
+----------------------+-------------------------------+----------------------+
| Илья Аянами          | PR-менеджер                   |   66375.39756536484  |
| all employees        | PR-менеджер                   |   66375.39756536484  |
| Джолин Геноза        | Администратор                 |   89394.29763185978  |
| all employees        | Администратор                 |   89394.29763185978  |
| Макима Узумаки       | Бармен                        |   87385.5            |
| all employees        | Бармен                        |   87385.5            |
| Миса Аканэ           | Гид-экскурсовод               |   29209.201160669327 |
| all employees        | Гид-экскурсовод               |   29209.201160669327 |
| Джотаро Мышь         | Горничная                     |   34824.59907746315  |
| all employees        | Горничная                     |   34824.59907746315  |
| Мива Мышь            | Директор                      |   87886.60246515274  |
| all employees        | Директор                      |   87886.60246515274  |
| Джорно Фубуки        | Консьерж                      |   63267.200942754745 |
| all employees        | Консьерж                      |   63267.200942754745 |
| Роуз Джостар         | Массажист                     |   20428.200811743736 |
| all employees        | Массажист                     |   20428.200811743736 |
| Миса Ленгли          | Медик                         |   73875.0            |
| all employees        | Медик                         |   73875.0            |
| Джорно Ленгли        | Менеджер                      |   79806.40118920803  |
| all employees        | Менеджер                      |   79806.40118920803  |
| Макима Мухаммед      | Менеджер по туризму           |   94346.60264635086  |
| all employees        | Менеджер по туризму           |   94346.60264635086  |
| Фэй Мышь             | Официант                      |   50003.998675346375 |
| all employees        | Официант                      |   50003.998675346375 |
| Джозеф Почитта       | Охранник                      |   52672.0            |
| all employees        | Охранник                      |   52672.0            |
| Даниил Агацума       | Повар                         |    7542.000112384558 |
| Фэй Лайт             | Повар                         |   13978.000208288431 |
| all employees        | Повар                         |   21520.00032067299  |
| Джорно Икари         | Портье                        |   20772.00082540512  |
| all employees        | Портье                        |   20772.00082540512  |
| Кира Бранде          | Спеиалист по связям с гостями |  162824.39568662643  |
| all employees        | Спеиалист по связям с гостями |  162824.39568662643  |
| Джозеф Геноза        | Техник                        |  108455.60235071182  |
| all employees        | Техник                        |  108455.60235071182  |
| Кира Амане           | Швейцар                       |  121764.0            |
| all employees        | Швейцар                       |  121764.0            |
| Константин Токийский | Шеф-повар                     |   36406.999379992485 |
| all employees        | Шеф-повар                     |   36406.999379992485 |
| all employees        | all specialities              | 1301218.0007293224   |
+----------------------+-------------------------------+----------------------+
40 rows in set
Time: 0.019s

# 2022-12-02 23:47:20.956194
quit;
Goodbye!

7. в MySql нет функционала для использования CUBE
