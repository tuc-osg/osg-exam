STUDENTS = tasks/students.xlsx
TASKS := $(wildcard tasks/*.tex) 


# Generate single exam without solutions.
exam: $(TASKS)
	pushd tasks; \
	latexmk -lualatex exam.tex; \
	popd 

# Generate single exam with solutions.
solution: $(TASKS)
	pushd tasks; \
	lualatex "\def\genanswers{}\input{exam.tex}"; \
	lualatex "\def\genanswers{}\input{exam.tex}"; \
	popd 
	mkdir -p tasks/pdf
	mv tasks/exam.pdf tasks/pdf/exam_solution.pdf

# Generate all exams.
exams: $(TASKS) $(STUDENTS)
	pushd lib; \
	python3 generate_exams.py ../$(STUDENTS); \
	popd 

roomexams: $(TASKS) $(STUDENTS)
	pushd lib; \
	python3 generate_roomexams.py ../$(STUDENTS) $(ROOMS); \
	popd 

# Generate room plans and entry check lists, needs ROOMS parameter
# Example: make ROOMS=201,N111 plans
plans: $(STUDENTS)
	pushd lib; \
	python3 generate_plans.py ../$(STUDENTS) $(ROOMS); \
	popd

clean:
	pushd tasks; latexmk -C; popd
	rm -rf lib/__pycache__
	rm -f tasks/*.aux
	rm -f tasks/*.log
	rm -f tasks/table_withname*.tex
	rm -f tasks/table_withoutname.tex
	rm -f tasks/exam.pdf
	rm -f tasks/solution.pdf
	rm -rf tasks/pdf
