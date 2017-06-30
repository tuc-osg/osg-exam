# Example-exam using latex exam class

This exam uses all the tricks we normally need for our exams. It generates the exams personalized for the use in envelopes.


## How to use the stuff
- For an english exam comment translations in setup.tex 
- For bilingual exams you can use \dep{} to give german translations for the descriptions (see tasks directory for examples).
- Add course name, abbreviation and term in exam_meta.tex
- generate .csv for the student details (last name; first name; student number)
- Change room in Makefile (See generate_sheets.py for details about which rooms are currently supported)
- Add Tasks for your exam
- During design you can simply call lualatex to generate only example.pdf
- If you are satisfied with your design, call make and be happy :)

- After correction you can use ects.py to generate your grade list.

## More details about the ingredients
- The generate_exams.py script generates one exam for each registered student and a plain one. 
- generate_sheets.py generates the room plans and registrations lists
- ects.py can be used to make a grading for the exams