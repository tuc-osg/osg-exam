import os
import sys
import shutil
import random
import os.path
from subprocess import call
from itertools import cycle

from xlsxparser import students

# Target folders
BASE_PATH = "../tasks/"
PDF_PATH = BASE_PATH + "pdf/"

# The available seat numbers per room
r201 = ('1-a', '1-b', '1-c', '1-d', '1-e', '1-f',
        '3-a', '3-b', '3-c', '3-d', '3-e', '3-f',
        '5-a', '5-b', '5-c', '5-d', '5-e', '5-f',
        '7-a', '7-b', '7-c', '7-d', '7-e', '7-f',
        '9-a', '9-b', '9-c', '9-d', '9-e', '9-f',
        '11-a', '11-b', '11-c', '11-d', '11-e', '11-f',
        '13-a', '13-b', '13-c', '13-d', '13-e', '13-f',
        '15-a', '15-b', '15-c', '15-d', '15-e', '15-f',
        '17-a', '17-b', '17-c', '17-d', '17-e', '17-f')

r316 = ('1-a', '1-b', '1-c', '1-d', '1-e', '1-f', '1-g', '1-h',
        '3-a', '3-b', '3-c', '3-d', '3-e', '3-f', '3-g', '3-h', '3-i',
        '5-a', '5-b', '5-c', '5-d', '5-e', '5-f', '5-g', '5-h', '5-i', '5-j',
        '7-a', '7-b', '7-c', '7-d', '7-e', '7-f', '7-g', '7-h', '7-i', '7-j', '7-k',
        '9-a', '9-b', '9-c', '9-d', '9-e', '9-f', '9-g', '9-h', '9-i', '9-j', '9-k',
        '11-a', '11-b', '11-c', '11-d', '11-e', '11-f', '11-g', '11-h', '11-i', '11-j')

r305 = ('1-a', '1-b', '1-c', '1-d', '1-e', '1-f',
        '3-a', '3-b', '3-c', '3-d', '3-e', '3-f',
        '5-a', '5-b', '5-c', '5-d', '5-e', '5-f',
        '7-b', '7-c', '7-d', '7-e')

rN115 = ('1-A', '1-B', '1-C', '1-D', '1-E', '1-F', '1-G', '1-H',    
         '3-A', '3-B', '3-C', '3-D', '3-E', '3-F', '3-G', '3-H', '3-I', '3-J', '3-K', '3-L',   
         '5-A', '5-B', '5-C', '5-D', '5-E', '5-F', '5-G', '5-H', '5-I', '5-J', '5-K', '5-L',   
         '7-A', '7-B', '7-C', '7-D', '7-E', '7-F', '7-G', '7-H', '7-I', '7-J', '7-K', '7-L',   
         '9-A', '9-B', '9-C', '9-D', '9-E', '9-F', '9-G', '9-H', '9-I', '9-J', '9-K', '9-L',   
         '11-A', '11-B', '11-C', '11-D', '11-E', '11-F', '11-G', '11-H', '11-I', '11-J', '11-K', '11-L',   
         '13-A', '13-B', '13-C', '13-D', '13-E', '13-F', '13-G', '13-H', '13-I', '13-J', '13-K', '13-L',   
         '15-A', '15-B', '15-C', '15-D', '15-E', '15-F', '15-G', '15-H', '15-I', '15-J', '15-K', '15-L',   
         '17-A', '17-B', '17-C', '17-D', '17-E', '17-F', '17-G', '17-H', '17-I', '17-J', '17-K', '17-L',   
         '19-A', '19-B', '19-C', '19-D', '19-E', '19-F', '19-G', '19-H', '19-I', '19-J', '19-K', '19-L',
         '21-A', '21-B', '21-C', '21-D', '21-E', '21-F', '21-G', '21-H', '21-I', '21-J', '21-K', '21-L')

rN114 = ('1-A', '1-B', '1-C', '1-D', '1-E', '1-F', '1-G', '1-H',    
         '3-A', '3-B', '3-C', '3-D', '3-E', '3-F', '3-G', '3-H', '3-I', '3-J',   
         '5-A', '5-B', '5-C', '5-D', '5-E', '5-F', '5-G', '5-H', '5-I', '5-J',   
         '7-A', '7-B', '7-C', '7-D', '7-E', '7-F', '7-G', '7-H', '7-I', '7-J',   
         '9-A', '9-B', '9-C', '9-D', '9-E', '9-F', '9-G', '9-H', '9-I', '9-J',   
         '11-A', '11-B', '11-C', '11-D', '11-E', '11-F', '11-G', '11-H', '11-I', '11-J',   
         '13-A', '13-B', '13-C', '13-D', '13-E', '13-F', '13-G', '13-H', '13-I', '13-J',   
         '15-A', '15-B', '15-C', '15-D', '15-E', '15-F', '15-G', '15-H', '15-I', '15-J',   
         '17-A', '17-B', '17-C', '17-D', '17-E', '17-F', '17-G', '17-H', '17-I', '17-J',   
         )

# The available rooms
avail_seats = {'201': r201, '316': r316, '305': r305, 'N115': rN115, 'N114': rN114}

########################################################################################
def genexam(firstname, lastname, studentid, room, seat):
    '''
            Generates an exam for the given student, if not existing.
            Target file is stored in "folder", with the student ID as file name.
    '''
    # safeguard for broken XLSX reading
    if not lastname or not firstname or not studentid or not room or not seat:
        return
    targetfile = PDF_PATH + studentid + '.pdf'
    if os.path.isfile(targetfile):
        print("Skipping generation of %s, because it exists ..." % targetfile)
        return
    else:
        print("Generating " + targetfile)

    call('latexmk -C', shell=True, cwd=BASE_PATH)
    # multiple runs needed by exam class
    cmdline = 'lualatex "\def\studentid{{{0}}}\def\studentname{{{1} {2}}}\def\proom{{{3}}}\def\place{{{4}}}\input{{exam.tex}}"'.format(
        studentid, firstname, lastname, room, seat)
    call(cmdline, shell=True, cwd=BASE_PATH)
    call(cmdline, shell=True, cwd=BASE_PATH)
    call(cmdline, shell=True, cwd=BASE_PATH)
    call(cmdline, shell=True, cwd=BASE_PATH)
    call(cmdline, shell=True, cwd=BASE_PATH)
    shutil.move(BASE_PATH + 'exam.pdf', targetfile)


def next_seat_gen(rooms):
    # Generate seat iterators
    seat_it = {room: iter(avail_seats[room]) for room in rooms}

    # Cycle through rooms and fetch new seat per room
    for room in cycle(rooms):
        seat = next(seat_it[room], None)
        if seat is None:   # room is full, remove from list
            rooms = [r for r in rooms if r != room]
            continue
        yield (room, seat)

    raise RuntimeError("Error: Not enough seats available.")


# Parse command-line arguments
if len(sys.argv) < 3:
    print("ERROR: Not enough arguments.")
    print("generate_plans.py <xlsx file> <room1,room2,...>")
    print("Check also the Makefile.")
    exit(-1)
xlsx_file = sys.argv[1]
room_list = sys.argv[2].split(',')

# Check room list
capacity = 0
for room in room_list:
    if room not in avail_seats.keys():
        print("ERROR: Room %s is not supported, please adjust generate_plans.py accordingly." % room)
        exit(-1)
    capacity += len(avail_seats[room])

# Fetch all students from XLSX, so that we can sort them
all_students = []
for first_name, last_name, student_id in students(xlsx_file):
    all_students.append(
        {'student_id': student_id, 'first_name': first_name, 'last_name': last_name})
all_students = sorted(all_students, key=lambda d: d['student_id'])

if len(all_students) > capacity:
    print("ERROR: The rooms only offer {0} seats, but we have {1} students.".format(
        capacity, len(all_students)))
    exit(-1)

# Lists with student names are generated per room
# Used for entry check in the room
withname = {}
for room in room_list:
    withname[room] = open(BASE_PATH + 'table_withname_{0}.tex'.format(room), 'w')
    withname[room].write("% Generated, do not edit.\n\n")

# Assign places to students
seats = next_seat_gen(room_list)
for stud in all_students:
    stud['room'], stud['seat'] = next(seats)
    print(stud)
    genexam(stud['first_name'], stud['last_name'], stud['student_id'], stud['room'], stud['seat'])
    withname[stud['room']].write(
        "{student_id} & {first_name} & {last_name} & {room} & {seat} \\\\\n".format(**stud))

for f in withname.values():
    f.close()

# Generate target folder, in case it does not exist
try:
    os.mkdir(PDF_PATH)
except Exception:
    pass

# Note: shutil.move() does not work when the target exists

for room in room_list:
    # The template TEX file always includes 'table_withname.tex'
    include_file = BASE_PATH + 'table_withname_{0}.tex'.format(room)
    os.rename(include_file, BASE_PATH + 'table_withname.tex')
    cmdline = 'lualatex ../lib/plan_withname.tex'
    call(cmdline, shell=True, cwd=BASE_PATH)
    shutil.copyfile(BASE_PATH + 'plan_withname.pdf',
                    PDF_PATH + 'plan_withname_{0}.pdf'.format(room))
    os.remove(BASE_PATH + 'plan_withname.pdf')

# Also generate a blank one. LaTex needs some content, so we use gibberish white space.
genexam('~', '~', '~', '~', '~')
