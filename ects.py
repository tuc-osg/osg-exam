#!/usr/bin/python
# -*- coding: utf-8 -*-

'''
	ECTS Notenberechnung.

	Eingabe ist eine CSV-Datei mit folgenden Eigenschaften:

	- Trennzeichen ist ";"
	- Kein Quoting
	- Titelzeile vorhanden
	- Spalten: Nachname;Vorname;Matrikelnummer;Status;Aufgabe 1;Aufgabe 2;Aufgabe ...;Gesamt
	- Status enthaelt "NE", wenn der Kandidat nicht erschienen ist

    - Aufruf: ects.py <Dateiname> <minimale Punkte zum Bestehen>

    Die Ermittlung der Noten erfolgt nach einem abgewandelten ECTS-Prinzip.
    Dabei wird der Punktebereich der bestehenden Studenten nach der ECTS-Prozentverteilung
    partitioniert. Daraus ergibt sich die Punkte->Noten-Tabelle, welche auf die Daten
    angewandt wird.

'''
import csv, sys, argparse
from pprint import pprint
from collections import defaultdict

parser = argparse.ArgumentParser(description='Berechnung von ECTS-Noten aus einer Punktetabelle.')
parser.add_argument('infile', metavar="input.csv", help='Eingabedatei im CSV-Format.')
parser.add_argument('minpoints', nargs=1, type=int, help='Minimale Punktanzahl zum Bestehen.')
parser.add_argument('--outfile', metavar="output.csv", default=None, help='Generierte Ausgabedatei im CSV-Format.')
args = parser.parse_args()
minpoints=args.minpoints[0]

scale=[					# Umrechnung deutsche Noten vs. ECTS vs. Anteil des Punktebereichs der bestandenen Studenten
	(1.0, 'A', 0.05),
	(1.3, 'A', 0.05),
    (1.7, 'B', 0.13),
    (2.0, 'B', 0.12),
    (2.3, 'C', 0.15),
    (2.7, 'C', 0.15),
    (3.0, 'D', 0.13),
    (3.3, 'D', 0.12),
    (3.7, 'E', 0.05),
    (4.0, 'E', 0.05)
]

failed=[]	# durchgefallene Studenten
ne=[]		# nicht erschienende Studenten
passed=[]	# bestandene Studenten

pointfreq=defaultdict(int)  	# Häufigkeit der Gesamtpunktzahl

# CSV-Datei einlesen und die drei Gruppen der Studenten ermitteln
with open(args.infile,'rU') as csvfile:
	reader=csv.reader(csvfile,  quoting=csv.QUOTE_NONE, delimiter=';')
	headers=reader.next()
	for row in reader:
		nachname, vorname=row[0:2]
		matrikel=int(row[2])
		status=row[3]
		#print("%s,%s (%s)"%(nachname, vorname, matrikel))
		if status!="NE":			# erschienen
			punkte=[int(element) if element.isdigit() else 0 for element in row[4:-1]]
			try:
				summe=int(row[-1])
			except:
				print("FEHLER: Letzte Spalte in der CSV-Datei muss den Summenwert enthalten")
				exit(-1)
			if summe<minpoints:		# durchgefallen
				failed.append((nachname, vorname, matrikel, punkte, summe))
			else:					# bestanden
				passed.append((nachname, vorname, matrikel, punkte, summe))
				pointfreq[summe]+=1
		else:					# nicht erschienen
			ne.append((nachname, vorname, matrikel, 0, 0))

# Statistik
numpassed=len(passed)
min_passed_points=min(pointfreq)
max_passed_points=max(pointfreq)

print "Bestanden: %u Studenten"%(numpassed)
print "Durchgefallen: %u Studenten"%(len(failed))
print "Nicht erschienen: %u Studenten"%(len(ne))

print "\nPunktehäufigkeit:"
print "-----------------"
for k in sorted(pointfreq, reverse=True):
	print "%u Punkte (%u) "%(k, pointfreq[k])+"*"*pointfreq[k]

# Ermittlung der Punkte -> Note Tabelle
pointtable=[]
point_mass=max_passed_points-min_passed_points
point_range_start=max_passed_points
for grade in scale:
	if grade[0]!=4.0:
		next_start=point_range_start-int(round(point_mass*grade[2]))
		pointtable.append((point_range_start, next_start+1, grade[0]))
		point_range_start=next_start
	else:
		pointtable.append((point_range_start, minpoints, 4.0))

# Ausdrucken der Punkte -> Noten Tabelle
print "\nResultierende Punktetabelle:"
print "------------------------------"
for entry in pointtable:
	if entry[0]==entry[1]:
		print("{} - {} Punkte".format(entry[2], entry[0]))
	else:
		print("{} - {} Punkte bis {} Punkte".format(entry[2], entry[0], entry[1]))

# Noten berechnen für die teilnehmenden Studenten
grades=[]
gradefreq=defaultdict(int)  	# Häufigkeit der Noten
for student in passed:
	points=student[4]
	matrikel=student[2]
	for pointrange in pointtable:
		if pointrange[0]>=points and points>=pointrange[1]:
			grades.append(student+(str(pointrange[2]),))  # Note hier als String, für späteren "NE" Vermerk
			gradefreq[pointrange[2]]+=1
			break
	else:
		print("FEHLER: Note nicht ermittelbar - "+str(student))
for student in failed:
	grades.append(student+("5.0",))
for student in ne:
	grades.append(student+("N.E.",))

# Histogram der Noten ausgeben
print "\nResultierende Notenhäufigkeit:"
print "--------------------------------"
for k in sorted(gradefreq, reverse=True):
	print "Note %.1f (%2u) "%(k, gradefreq[k])+"*"*gradefreq[k]

# Komplettes Ergebnis nach Nachnamen sortiert ausgeben
students_sorted=sorted(grades)
print "\nNoten der Studenten:"
print "----------------------"
for stud in students_sorted:
	print("{:>20} {:>20} {:>8} {:>8} ({:>2} Punkte)".format(stud[0], stud[1], stud[2], stud[5], stud[4]))

# Ausgabedatei produzieren
if args.outfile:
    with open(args.outfile, 'wb') as outfile:
    	csvwriter = csv.writer(outfile)
    	for stud in students_sorted:
            csvwriter.writerow([stud[2], stud[5], stud[4]])

