#!/usr/bin/env python3

import random
import string
import sys
from faker import Faker
import datetime


def people_data( full_name, age, passport, sex ):
    return f"('{full_name}', {age}, '{passport}', '{sex}')";

if __name__ == "__main__":
    Faker.seed(0)
    faker = Faker()
    hotel_order_num = 20
    people_num = 20
    max_room_num = 20
    people_names = ['Джотаро', 'Джозеф', 'Джонатан', 'Джорно', 'Джолин', 'Даниил', 'Константин', 'Илья', 'Сайтама', 'Шигео', 'Дива', 'Кира', 'Цунемори', 'Жоржи', 'Мива', 'Сасаки','Фэй','Роуз','Миса', 'Макима', 'Рей', 'Синдзи', 'Аска'];
    people_second_names = ['Токийский', 'Куджо', 'Мухаммед', 'Джостар', 'Геноза', 'Лайт', 'Йошикаге', 'Бранде', 'Агацума', 'Аканэ', 'Амане', 'Узумаки', 'Мышь', 'Фубуки', 'Почитта', 'Аянами', 'Ленгли','Икари', 'Макинами']
    sexes = ['Not known', 'Male', 'Female', 'Not applicable']
    if len( sys.argv ) == 1:
        output_file_name = "gen_data.sql"
    else:
        output_file_name = sys.argv[ 1 ]

    real_names = False

    room_class = ['vip', 'standart', 'half vip']
    passports = []
    passport = 0
    with open( output_file_name, "w" ) as output_file:
        output_file.write( "insert into People (Full_name, Age, Passport, Sex) values\n" )
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
        output_file.write(";\ninsert into HotelOrder ( DateInfo, Price, Stars, person_id, room_id ) values\n")
        for i in range( hotel_order_num ):
            random.seed()
            output_file.write(
                f"('{faker.date_time_between( '-50y', 'now' ).strftime('%Y-%m-%d %H:%M:%S')}', "
                + f"{random.randint( 1000, 550000 )}, {random.randint( 0, 5 )}, {random.randint( 1, people_num )}, "
                + f"{random.randint( 1, room_num )})"
            )
            if i != hotel_order_num - 1:
                output_file.write(",\n")
        output_file.write( ";\n" )
