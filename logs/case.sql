1.  выбираем всех покупателей, которые находятся в чёрном списке и записываем, когда они были в последний раз в отеле

# 2022-12-02 22:12:55.910689
select

c.customer_id, p.FullName,

case
when (select DATE_ADD( max(h.DateInfo), interval 20 year) < now() from HotelOrder h where h.customer_id = c.customer_id)
then '> 20 years'
when (select DATE_ADD( max(h.DateInfo), interval 10 year) < now() from HotelOrder h where h.customer_id = c.customer_id)
then '> 10 years'
else '< 10 years'
end as 'date'

from
`Customer` c join `PersonInfo` p on c.customer_id = p.person_id where c.`InBlackList` = true; 
+-------------+---------------+------------+
| customer_id | FullName      | date       |
+-------------+---------------+------------+
| 7           | Мива Ленгли   | < 10 years |
| 17          | Сайтама Аканэ | > 10 years |
| 40          | Рей Аянами    | < 10 years |
+-------------+---------------+------------+
3 rows in set
Time: 0.034s


2. Разделяем всех людей на тех, кто работает ночью, во вторую половину дня, в первую половину дня или просто в течение дня.


# 2022-12-02 22:27:45.894420
select e.employee_id, p.FullName, e.`TimeIn`, e.`TimeOut` from `Employee` e join `PersonInfo` p on e.employee_id = p.person_id
+-------------+----------------------+----------+----------+
| employee_id | FullName             | TimeIn   | TimeOut  |
+-------------+----------------------+----------+----------+
| 5           | Джолин Геноза        | 6:11:34  | 22:51:18 |
| 6           | Кира Бранде          | 15:10:05 | 21:13:32 |
| 9           | Константин Токийский | 9:45:25  | 20:47:54 |
| 11          | Макима Мухаммед      | 7:18:30  | 14:59:45 |
| 13          | Миса Ленгли          | 6:53:21  | 20:22:57 |
| 14          | Джозеф Почитта       | 0:43:14  | 6:59:17  |
| 15          | Фэй Мышь             | 5:50:04  | 10:22:43 |
| 16          | Джотаро Мышь         | 15:12:50 | 17:28:10 |
| 18          | Мива Мышь            | 7:33:26  | 20:29:10 |
| 21          | Роуз Джостар         | 11:25:28 | 16:40:02 |
| 23          | Джозеф Геноза        | 17:11:51 | 3:09:34  |
| 25          | Илья Аянами          | 18:37:56 | 0:50:09  |
| 27          | Даниил Агацума       | 12:12:42 | 22:16:57 |
| 28          | Джорно Икари         | 14:54:27 | 18:36:24 |
| 31          | Джорно Фубуки        | 7:04:36  | 18:22:11 |
| 33          | Фэй Лайт             | 11:21:15 | 17:20:09 |
| 35          | Макима Узумаки       | 15:00:21 | 23:09:39 |
| 37          | Кира Амане           | 7:03:02  | 18:02:09 |
| 38          | Миса Аканэ           | 7:30:53  | 20:30:00 |
| 39          | Джорно Ленгли        | 7:21:55  | 16:14:44 |
+-------------+----------------------+----------+----------+
20 rows in set
Time: 0.018s

# 2022-12-13 12:11:19.224831
select e.employee_id, p.FullName,
case
when (e.TimeIn > '12:00:00') and (e.TimeOut < '12:00:00') then 'Работает ночью'
when (e.TimeIn > '12:00:00') and (e.TimeOut < '24:00:00') then 'Работает во вторую половину дня'
when (e.TimeIn > '3:00:00') and (e.TimeOut < '15:00:00') then 'Работает в первую половину дня'
when (e.TimeIn > '6:00:00') and (e.TimeOut < '20:00:00') then 'Работает в течение дня'
else 'Работает весь день'
end as `время работы`
from `Employee` e join `PersonInfo` p on e.employee_id = p.person_id;
+-------------+----------------------+---------------------------------+
| employee_id | FullName             | время работы                    |
+-------------+----------------------+---------------------------------+
| 5           | Джолин Геноза        | Работает весь день              |
| 6           | Кира Бранде          | Работает во вторую половину дня |
| 9           | Константин Токийский | Работает весь день              |
| 11          | Макима Мухаммед      | Работает в первую половину дня  |
| 13          | Миса Ленгли          | Работает весь день              |
| 14          | Джозеф Почитта       | Работает весь день              |
| 15          | Фэй Мышь             | Работает в первую половину дня  |
| 16          | Джотаро Мышь         | Работает во вторую половину дня |
| 18          | Мива Мышь            | Работает весь день              |
| 21          | Роуз Джостар         | Работает в течение дня          |
| 23          | Джозеф Геноза        | Работает ночью                  |
| 25          | Илья Аянами          | Работает ночью                  |
| 27          | Даниил Агацума       | Работает во вторую половину дня |
| 28          | Джорно Икари         | Работает во вторую половину дня |
| 31          | Джорно Фубуки        | Работает в течение дня          |
| 33          | Фэй Лайт             | Работает в течение дня          |
| 35          | Макима Узумаки       | Работает во вторую половину дня |
| 37          | Кира Амане           | Работает в течение дня          |
| 38          | Миса Аканэ           | Работает весь день              |
| 39          | Джорно Ленгли        | Работает в течение дня          |
+-------------+----------------------+---------------------------------+
20 rows in set
Time: 0.028s


3. Создаём функцию, которая вычисляет для какого-то человка, больше ли его зарплата чем МРОТ.


# 2022-12-14 01:50:34.653706
create function salary_assessment( ename nchar(100) )
returns nchar(100)
deterministic reads sql data
begin
    declare no_such_employee condition for sqlstate 'NOSEM';
    declare too_many_employees condition for sqlstate 'TMAEM';
    declare assessment nchar(100);
    declare wage float default 23508;
    declare rows_num int;
    drop temporary table if exists salary_assessment_tmp;
    create temporary table salary_assessment_tmp (
        select
        case
            when (e.Salary * e.Rate > wage * 3) then 'Больше 3-х МРОТ'
            when (e.Salary * e.Rate > wage * 2) then 'Больше 2-х МРОТ'
            when (e.Salary * e.Rate > wage ) then 'Больше МРОТ'
            else 'Меньше МРОТ'
        end as Salary
        from `EmployeeDetailedInfo` e join ( select * from `PersonInfo` where FullName = ename ) p
        on e.employee_id = p.person_id
    );
    case (select count(*) from salary_assessment_tmp)
    when 0 then
        signal no_such_employee set message_text = 'there is no such employee with this name';
    when 1 then
        select * into assessment from salary_assessment_tmp;
        return assessment;
    else
        signal too_many_employees set message_text = 'many employees with similar name';
    end case;
    return assessment;
end//
Query OK, 0 rows affected
Time: 0.030s

# 2022-12-14 02:00:07.686221
select e.Speciality, p.FullName as FullName, salary_assessment(p.FullName) as salary
from `PersonInfo` p join
(select * from Employee where Speciality in ('Повар', 'Шеф-повар')) e
on p.person_id = e.employee_id
+------------+----------------------+-------------+
| Speciality | FullName             | salary      |
+------------+----------------------+-------------+
| Шеф-повар  | Константин Токийский | Больше МРОТ |
| Повар      | Даниил Агацума       | Меньше МРОТ |
| Повар      | Фэй Лайт             | Меньше МРОТ |
+------------+----------------------+-------------+
3 rows in set
Time: 0.028s
