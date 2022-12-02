#!/usr/bin/env python3

import random
import string
import sys
from faker import Faker
import datetime
import copy

def people_data( full_name, age, passport, sex ):
    return f"('{full_name}', {age}, '{passport}', '{sex}')";

if __name__ == "__main__":
    Faker.seed(0)
    faker = Faker()
    hotel_order_num = 40
    people_num = 40
    max_room_num = 20
    customers_num = 20
    employee_num = people_num - customers_num
    people_ids = []
    for i in range( people_num ):
        people_ids.append( i )
    wrong_behaviour = ['Кража халата', 'Разбит стакан',
                       'Готовка вне кухни', 'Оставлены ценные вещи вне сейфа', 
                       'Курение в номере', 'Разбита ваза', 'Мешали другим' ]
    people_names = ['Джотаро', 'Джозеф', 'Джонатан', 'Джорно', 'Джолин',
                    'Даниил', 'Константин', 'Илья', 'Сайтама', 'Шигео',
                    'Дива', 'Кира', 'Цунемори', 'Жоржи', 'Мива', 'Сасаки',
                    'Фэй','Роуз','Миса', 'Макима', 'Рей', 'Синдзи', 'Аска'];
    people_second_names = ['Токийский', 'Куджо', 'Мухаммед', 'Джостар',
                           'Геноза', 'Лайт', 'Йошикаге', 'Бранде',
                           'Агацума', 'Аканэ', 'Амане', 'Узумаки',
                           'Мышь', 'Фубуки', 'Почитта', 'Аянами',
                           'Ленгли','Икари', 'Макинами']
    sexes = ['Not known', 'Male', 'Female', 'Not applicable']
    specialities = [ 'Администратор', 'Менеджер', 'Горничная',
                     'Швейцар', 'Консьерж', 'Портье', 'Техник', 'Метрдотель',
                     'Повар', 'Повар',  'Повар', 'Официант', 'Официант', 'Официант',
                     'Охранник', 'Аниматор', 'Медик',
                     'Массажист', 'Крупье', 'Спеиалист по связям с гостями', 'PR-менеджер',
                     'Менеджер по туризму', 'Гид-экскурсовод', 'Туроператор', 'Бармен'
                    ]


    if len( sys.argv ) == 1:
        output_file_name = "gen_data.sql"
    else:
        output_file_name = sys.argv[ 1 ]

    real_names = False

    room_class = ['vip', 'standart', 'half vip']
    passports = []
    passport = 0
    with open( output_file_name, "w" ) as output_file:
        output_file.write( "insert into PersonInfo (FullName, Age, Passport, Sex) values\n" )
        for i in range( people_num ):
            random.seed()
            if not real_names:
                cur_name = f"{random.choice( people_names )} {random.choice( people_second_names )}"
            else:
                cur_name = faker.name()
            while passports.count( ( passport := random.randint( 1000000000, 10000000000 ) ) ):
                pass
            output_file.write(
                people_data(
                    cur_name, random.randint( 1, 101 ),
                    passport, random.choice( sexes )
                )
            )
            if i != people_num - 1:
                output_file.write(",\n")

        output_file.write( ";\ninsert into Customer ( WrongBehaviour, `Status`, `HavePets`, InBlackList, customer_id ) values\n" )

        customer_ids = []
        for i in range( customers_num ):
            random.seed()
            cur_id_idx = random.randint( 0, len( people_ids ) - 1 )
            cur_beh = [random.choice( wrong_behaviour ) for i in range( random.randint( 1, 4 ) )]
            cur_beh_str = ""
            for j in range( len( cur_beh ) - 1 ):
                cur_beh_str += cur_beh[ j ] + ", "
            cur_beh_str += cur_beh[ len( cur_beh ) - 1 ]
            output_file.write(
                "("
                + ( f"'{cur_beh_str}'" if random.randint( 1, 8 ) > 6 else "null" )
                + f", "
                + ( "'vip'" if random.randint( 1, 8 ) > 6 else ( "null" if random.randint( 1, 8 ) > 6 else "'standart'" ) )
                + ", "
                + ( "TRUE" if random.randint( 1, 8 ) > 6 else "FALSE" )
                + ", "
                + ( "TRUE" if random.randint( 1, 100 ) > 95 else "FALSE" )
                + f", {people_ids[ cur_id_idx ] + 1})"
            )
            customer_ids.append( people_ids.pop( cur_id_idx ) )
            if i != customers_num - 1:
                output_file.write(",\n")


        output_file.write( ";\ninsert into Room ( Floor, `Number`, `Class`, Capacity ) values\n" )

        floor = 0
        room_num = 0
        while room_num < max_room_num:
            random.seed()
            if floor != 0:
                output_file.write(",\n")
            floor += 1
            cur_room_num = min( random.randint( 1, max_room_num - room_num ), max_room_num // 4 )
            for i in range( cur_room_num ):
                output_file.write(
                    f"({floor}, {i + 1}, "
                    + f"'{random.choice( room_class )}', {random.randint( 1, 4 )})"
                )
                if i != cur_room_num - 1:
                    output_file.write(",\n")
            room_num += cur_room_num
        output_file.write(";\ninsert into HotelOrder ( DateInfo, Price, Stars, customer_id, room_id ) values\n")
        for i in range( hotel_order_num ):
            random.seed()
            output_file.write(
                f"('{faker.date_time_between( '-50y', 'now' ).strftime('%Y-%m-%d %H:%M:%S')}', "
                + f"{random.randint( 1000, 550000 )}, {random.randint( 0, 5 )}, {random.choice( customer_ids ) + 1}, "
                + f"{random.randint( 1, room_num )})"
            )
            if i != hotel_order_num - 1:
                output_file.write(",\n")

        employee_ids = copy.deepcopy( people_ids )

        fake = Faker(locale="ru_RU")
        output_file.write(";\ninsert into Employee( Speciality, PhoneNumber, TimeIn, TimeOut, employee_id ) values\n")
        for i in range( employee_num ):
            random.seed()
            cur_id_idx_spec = random.randint( 0, len( specialities ) - 1 )
            cur_id_idx_people = random.randint( 0, len( people_ids ) - 1 )
            time_in = faker.date_time_between( '-24h', 'now' )
            time_out = faker.date_time_between( time_in, '+12h' )
            output_file.write(
                f"('{specialities[ cur_id_idx_spec ]}', '+{random.randint(6000000000, 9000000000 )}', "
                + f"'{ time_in.strftime('%H:%M:%S') }', '{ time_out.strftime('%H:%M:%S') }', "
                + f"{ people_ids[ cur_id_idx_people ] + 1 })"
            )
            specialities.pop( cur_id_idx_spec )
            people_ids.pop( cur_id_idx_people )
            if i != employee_num - 1:
                output_file.write(",\n")

        output_file.write(";\ninsert into EmployeeDetailedInfo( Salary, Rate, Address, supervisor_id, employee_id ) values\n")

        faker = Faker('ru_RU')
        default = employee_ids[ 0 ]
        for i in range( employee_num ):
            random.seed()
            cur_id_idx_empl = random.randint( 0, len( employee_ids ) - 1 )

            output_file.write(
                f"({ random.randint( 30000, 100000 ) }, "
                + f"{ format(random.randint( 0, 1 ) + random.randint( 0, 9 ) * 0.1, '.1f') }, "
                + f"'Москва, { faker.street_name() }, { faker.building_number() }', "
                + f"{default + 1}, "
                + f"{ employee_ids[ cur_id_idx_empl ] + 1 })"
            )
            if i != employee_num - 1:
                output_file.write(",\n")
            employee_ids.pop( cur_id_idx_empl )



        output_file.write( ";\n" )
