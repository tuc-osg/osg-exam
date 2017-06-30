# Bedienungsanleitung:
#
# teilnehmer.csv sollte die Daten der Studenten enthalten
# exam_meta.tex sollte den Titel der Pruefung enthalten
# Der Raum sollte hier definiert werden
# Anschließend können per 'make' die Klausuren und die Raumpläne
# generiert werden

ROOM=N012
all: teilnehmer.csv exam
	python generate_exams.py
	python generate_sheets.py $(ROOM)
	cp roomplan.pdf pdf/
	cp roomentry.pdf pdf/
	latexmk -C
	latexmk -C
	latexmk -C

exam:
	lualatex exam.tex

clean:
	rm -f exam.pdf
	rm -f roomentry.pdf
	rm -f roomplan.pdf
	latexmk -C
	latexmk -C
	latexmk -C


