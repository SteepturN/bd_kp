1. Процедура, которая выдаёт сумму всех трат для 1 человека

# 2022-12-12 15:53:23.923595
delimiter //
create procedure expenses( in n nchar(100), in passport nchar(100), out exp int )
begin
select sum( h.`Price` ) into exp from
(`Customer` c join `HotelOrder` h using(customer_id))
join `PersonInfo` p on p.person_id = c.customer_id
where p.FullName = n and p.Passport = passport;
end//
delimiter ;
Changed delimiter to //
Time: 0.004s

Query OK, 0 rows affected
Time: 0.071s

Changed delimiter to ;
Time: 0.000s

# 2022-12-12 15:58:05.954481
call expenses('Джозеф Бранде', '9439214161', @dbexp);
Query OK, 1 row affected
Time: 0.003s

# 2022-12-12 15:58:17.789696
select @dbexp;
+--------+
| @dbexp |
+--------+
| 42590  |
+--------+
1 row in set
Time: 0.009s

2. Процедура, которая записывает во временную таблицу сумму трат для людей с именем, которое посылают в качестве параметра, если нет покупателя с данным именем, бросается исключение

# 2022-12-13 02:37:42.444982
create procedure expenses_name( in n nchar(100) )
begin
    declare no_such_person condition for sqlstate '22012';

    drop temporary table if exists expenses_name_tmp;
    create temporary table expenses_name_tmp (
        select sum( h.`Price` ) as `expenses`, p.Passport from
        (`Customer` c join `HotelOrder` h using(customer_id))
        join `PersonInfo` p on p.person_id = c.customer_id
        where p.FullName = n group by p.Passport
    );
    if not exists( select * from expenses_name_tmp ) then signal no_such_person;
    end if;

end//
Query OK, 0 rows affected
Time: 0.087s

3. процедура, которая возвращает в качестве параметра сумму трат покупателя; она вызывает предыдущую процедуру, обрабатывает возможность получения исключения из предыдущей процедуры выводя таблицу null.

# 2022-12-13 02:38:00.544748
create procedure expenses( in n nchar(100), in passport nchar(100), out exp int )
begin
    declare no_such_person condition for sqlstate '22012';
    declare exit handler for no_such_person
    begin
        select null as person;
        set exp = null;
    end;

    call expenses_name( n );


    select ent.`expenses` into exp from
    expenses_name_tmp ent join `PersonInfo` p on ent.Passport = p.Passport
    where p.Passport = passport;

end//
Query OK, 0 rows affected
Time: 0.142s


# 2022-12-13 11:09:21.088607
call expenses( 'Джозеф Бранде', '9439214161', @out )
Query OK, 1 row affected
Time: 0.004s

# 2022-12-13 11:09:33.426463
select @out
+-------+
| @out  |
+-------+
| 42590 |
+-------+
1 row in set
Time: 0.010s


# 2022-12-13 11:10:25.571716
call expenses( 'Джозеф Брандо', '9439214161', @out )
+--------+
| person |
+--------+
| <null> |
+--------+
1 row in set
Time: 0.010s

# 2022-12-13 11:10:32.629151
select @out
+--------+
| @out   |
+--------+
| <null> |
+--------+
1 row in set
Time: 0.007s











-- функция - находит размер зп с учётом ставки (перемножает) + проверка на неотрицательность
--         - объединяет все заказы в одну строку
-- триггер - при добавлении в hotelorders проверка на то, что чела нет в чёрном списке
--         - при удалении челика-супервизора ставим всем нуллы, у кого он являлся супервизором

4. функция, которая высчитывает зарплату по имени сотрудника, если сотрудников с таким именем несколько - бросается исключение, если зарплвта получается отрицательной - бросается исключение


# 2022-12-13 04:09:56.885010
create function salary( ename nchar(100) )
returns float
deterministic reads sql data
begin
    declare too_many_employees condition for sqlstate 'TMAEM';
    declare no_such_employee condition for sqlstate 'NOSEM';
    declare something_wrong_with_salary_rate condition for sqlstate 'SWWSR';
    declare salary float;
    drop temporary table if exists salary_tmp;
    create temporary table salary_tmp (
        select e.Salary * e.Rate as `salary` from
        EmployeeDetailedInfo e join
        ( select * from PersonInfo where FullName = ename ) p
        on e.employee_id = p.person_id
    );
    if ( select count(*) from salary_tmp ) > 1 then
        signal too_many_employees set message_text = 'many employees with similar name';
    elseif ( select count(*) from salary_tmp ) = 0 then
        signal no_such_employee set message_text = 'there is no such employee with this name';
    else
        select * into salary from salary_tmp;
        if salary <= 0 then
           signal something_wrong_with_salary_rate set message_text = 'negative salary';
        end if;
    end if;
    return salary;
end//
Query OK, 0 rows affected
Time: 0.075s

# 2022-12-13 11:21:16.261191
select salary(`FullName`) from `PersonInfo`
(1644, 'there is no such employee with this name')

# 2022-12-13 11:21:59.129889
select salary(p.`FullName`) from `PersonInfo` p join `Employee` e on p.person_id = e.employee_id
+----------------------+
| salary(p.`FullName`) |
+----------------------+
|  89394.3             |
| 162824.0             |
|  36407.0             |
|  94346.6             |
|  73875.0             |
|  52672.0             |
|  50004.0             |
|  34824.6             |
|  87886.6             |
|  20428.2             |
| 108456.0             |
|  66375.4             |
|   7542.0             |
|  20772.0             |
|  63267.2             |
|  13978.0             |
|  87385.5             |
| 121764.0             |
|  29209.2             |
|  79806.4             |
+----------------------+
20 rows in set
Time: 0.069s


5.  создаём триггер, который срабатывает до вставки в таблицу HotelOrder и проверяет, находится ли человек в чёрном списке, и если находится, то бросается исключение


# 2022-12-13 04:44:56.613943
create trigger is_in_black_list before insert on `HotelOrder`
for each row
begin
    declare in_black_list condition for sqlstate 'IBLST';
    if ( select InBlackList from Customer where customer_id = new.customer_id ) then
       signal in_black_list set message_text = 'person is in black list';
    end if;
end//
Query OK, 0 rows affected
Time: 0.063s

# 2022-12-13 11:25:14.356638
insert into HotelOrder ( DateInfo, Price, Stars, customer_id, room_id ) values
('2022-12-13 16:56:00', 90000, null, 17, 4)
(1644, 'person is in black list')

# 2022-12-13 11:25:49.523739
select * from `HotelOrder` where `DateInfo` = '2022-12-13 16:56:00'
+----------+-------+-------+-------------+---------+----------+
| DateInfo | Price | Stars | customer_id | room_id | order_id |
+----------+-------+-------+-------------+---------+----------+
+----------+-------+-------+-------------+---------+----------+
0 rows in set
Time: 0.008s



6.  создаём триггер, который срабатывает до вставки в таблицу HotelOrder и проверяет, находится ли человек в чёрном списке, и если находится, то бросается исключение



# 2022-12-13 04:55:25.357378
create trigger supervisor_drop before delete on Employee
for each row
update EmployeeDetailedInfo set supervisor_id = null
where supervisor_id = old.employee_id//
Query OK, 0 rows affected
Time: 0.071s

# 2022-12-13 11:36:29.253374
delete from `PersonInfo` where person_id = 5
(1451, 'Cannot delete or update a parent row: a foreign key constraint fails (`kp`.`Employee`, CONSTRAINT `Employee_ibfk_1` FOREIGN KEY (`employee_id`) REFERENCES `PersonInfo` (`person_id`))')


6.  создаём триггер, который срабатывает до удаления из таблицы Employee и удаляет запись из таблицы EmployeeDetailedInfo

# 2022-12-13 11:34:45.743202
create trigger employee_drop before delete on Employee
for each row follows supervisor_drop
delete from EmployeeDetailedInfo where employee_id = old.employee_id;
Query OK, 0 rows affected
Time: 0.019s

7.  создаём триггер, который срабатывает до удаления из таблицы PeopleInfo и проверяет, находится ли человек в таблицах Employee или Customer, и если находится, то удаляется сначала оттуда

# 2022-12-13 05:20:19.787745
create trigger person_drop before delete on PersonInfo
for each row
begin
if exists( select * from Employee where employee_id = old.person_id ) then
   delete from Employee where employee_id = old.person_id;
elseif exists( select * from Customer where customer_id = old.person_id ) then
   delete from Customer where customer_id = old.person_id;
end if;
end//
Query OK, 0 rows affected
Time: 0.054s
Your call!

# 2022-12-13 04:56:45.811931
select supervisor_id, count( supervisor_id ) from `EmployeeDetailedInfo` group by supervisor_id//
+---------------+------------------------+
| supervisor_id | count( supervisor_id ) |
+---------------+------------------------+
| <null>        | 0                      |
| 5             | 14                     |
| 9             | 2                      |
| 39            | 3                      |
+---------------+------------------------+
4 rows in set
Time: 0.012s
Your call!

# 2022-12-13 11:43:50.065046
delete from `PersonInfo` where person_id = 5
Query OK, 1 row affected
Time: 0.072s

# 2022-12-13 11:44:13.754299
select supervisor_id, count( * ) from `EmployeeDetailedInfo` group by supervisor_id//
+---------------+------------+
| supervisor_id | count( * ) |
+---------------+------------+
| <null>        | 14         |
| 9             | 2          |
| 39            | 3          |
+---------------+------------+
3 rows in set
Time: 0.010s
